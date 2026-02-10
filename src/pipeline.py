# Purpose    : Download stock prices and FF5 factors, compute log excess returns, merge and export
# Data source: Yahoo Finance (yfinance) + Ken French Data Library (direct HTTP ZIP)
# Output     : data/processed/ff5_daily.csv
# Author     : Antoine C. and Noah D.-G.
# Date       : 2026-03

import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd
import requests
import yfinance as yf

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

TICKERS = ["MSFT", "AAPL", "GOOGL", "META"]
START_DATE = "2021-01-01"
END_DATE = "2025-12-31"

# Direct ZIP URL — stable for 10+ years, no extra dependency (vs pandas-datareader)
FF5_URL = (
    "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/"
    "F-F_Research_Data_5_Factors_2x3_daily_CSV.zip"
)

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_PATH = PROJECT_ROOT / "data" / "processed" / "ff5_daily.csv"


# ---------------------------------------------------------------------------
# Data acquisition
# ---------------------------------------------------------------------------


def download_prices() -> pd.DataFrame:
    """Download split- and dividend-adjusted daily close prices for all tickers.

    auto_adjust=True is explicit because yfinance 0.2.x changed the default
    and older tutorials still show the now-broken ["Adj Close"] pattern.
    """
    raw_prices = yf.download(
        TICKERS,
        start=START_DATE,
        end=END_DATE,
        auto_adjust=True,
        progress=False,
    )

    # Multi-ticker download returns a two-level MultiIndex: (price_type, ticker).
    # Selecting ["Close"] yields a single-level DataFrame with one column per ticker.
    close_prices = raw_prices["Close"]

    # Normalize to timezone-naive dates so the merge with Ken French data
    # (which uses plain calendar dates) does not silently shift observations.
    if close_prices.index.tz is not None:
        close_prices.index = close_prices.index.tz_localize(None)
    close_prices.index = close_prices.index.normalize()

    return close_prices


def download_ff5_factors() -> pd.DataFrame:
    """Download and parse daily FF5 factors from the Ken French Data Library.

    The CSV inside the ZIP has several header lines of metadata before the
    actual data. We locate the header row by finding the line that contains
    "Mkt-RF", which is always the first column name.

    Critical: Ken French distributes factors in percentage units (e.g., 0.25
    means 0.25%), not decimals. We divide by 100 immediately so units match
    the stock log returns.
    """
    response = requests.get(FF5_URL, timeout=60)
    response.raise_for_status()

    with zipfile.ZipFile(io.BytesIO(response.content)) as archive:
        csv_filename = archive.namelist()[0]
        with archive.open(csv_filename) as csv_file:
            raw_text = csv_file.read().decode("utf-8")

    lines = raw_text.splitlines()

    # Find the line index where the actual column header row begins
    header_line_index = next(
        i for i, line in enumerate(lines) if "Mkt-RF" in line
    )

    factors_raw = pd.read_csv(
        io.StringIO("\n".join(lines[header_line_index:])),
        index_col=0,
        skipinitialspace=True,
    )

    # The file appends annual summary rows after the daily data section.
    # Drop any rows where the index cannot be parsed as a valid YYYYMMDD date.
    valid_date_mask = pd.to_numeric(factors_raw.index, errors="coerce").notna()
    factors_raw = factors_raw[valid_date_mask]

    # Parse the integer YYYYMMDD index into proper datetime objects
    factors_raw.index = pd.to_datetime(
        factors_raw.index.astype(str), format="%Y%m%d"
    )
    factors_raw.index = factors_raw.index.normalize()

    # Convert from percent to decimal — this is the single most common
    # student error in FF regressions; a beta of 0.01 instead of ~1.0
    # signals this conversion was omitted.
    factors_decimal = factors_raw / 100

    # Rename to lowercase with underscores for clean R-compatible column names
    factors_decimal.columns = ["mkt_rf", "smb", "hml", "rmw", "cma", "rf"]

    # Filter to the study period
    factors_decimal = factors_decimal.loc[START_DATE:END_DATE]

    return factors_decimal


# ---------------------------------------------------------------------------
# Return computation
# ---------------------------------------------------------------------------


def compute_log_returns(prices: pd.DataFrame) -> pd.DataFrame:
    """Compute daily log returns for each ticker.

    Log returns are additive across periods and are the standard in the
    asset pricing literature (Fama-French use continuously compounded returns).
    The first row becomes NaN from the shift — it is dropped explicitly so
    the merge with FF5 factors does not silently introduce a missing value row.
    """
    log_returns = np.log(prices / prices.shift(1))
    log_returns = log_returns.dropna()

    # Lowercase column names for consistency with the factor column naming
    log_returns.columns = [ticker.lower() for ticker in log_returns.columns]

    return log_returns


# ---------------------------------------------------------------------------
# Dataset assembly
# ---------------------------------------------------------------------------


def build_dataset() -> pd.DataFrame:
    """Download all sources, compute log excess returns, and merge into one DataFrame.

    Inner join ensures only dates present in both yfinance and Ken French data
    are kept, eliminating any calendar mismatch without NaN rows.

    Excess return = log return - risk-free rate (both in decimal).
    This is the correct left-hand side variable for the FF5 regression.
    """
    print("Downloading stock prices from Yahoo Finance...")
    close_prices = download_prices()

    log_returns = compute_log_returns(close_prices)

    print("Downloading FF5 factors from Ken French Data Library...")
    factors = download_ff5_factors()

    # Inner merge on date index: only keeps NYSE trading days present in both sources
    print(f"Stock return rows before merge: {len(log_returns)}")
    print(f"Factor rows before merge: {len(factors)}")

    merged = log_returns.join(factors, how="inner")

    print(f"Merged rows after inner join: {len(merged)}")

    # Excess return: stock log return minus the risk-free rate (already in decimal)
    # Both sides are now in decimal units — the / 100 conversion above ensures this.
    for ticker in TICKERS:
        merged[f"{ticker.lower()}_excess"] = merged[ticker.lower()] - merged["rf"]

    # Select only the columns R needs, in the documented order
    final_columns = [
        "mkt_rf", "smb", "hml", "rmw", "cma", "rf",
        "msft_excess", "aapl_excess", "googl_excess", "meta_excess",
    ]
    dataset = merged[final_columns].copy()

    # Reset index so date becomes a plain column (ISO format, R reads it cleanly).
    # Name the index explicitly before resetting so the column name is predictable.
    dataset.index.name = "date"
    dataset = dataset.reset_index()
    dataset["date"] = pd.to_datetime(dataset["date"]).dt.strftime("%Y-%m-%d")

    return dataset


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------


def validate_dataset(df: pd.DataFrame) -> None:
    """Assert that the final dataset meets all structural and scale requirements.

    These checks catch the most common pipeline errors before the CSV is written:
    - Wrong number of columns (merge or column selection issue)
    - Missing values (NaN from log return shift, failed date merge)
    - Scale error (Ken French % not converted to decimal — beta would be ~0.01)
    - Unreasonable row count (calendar mismatch, wrong date range)
    """
    expected_columns = [
        "date", "mkt_rf", "smb", "hml", "rmw", "cma", "rf",
        "msft_excess", "aapl_excess", "googl_excess", "meta_excess",
    ]

    assert len(df.columns) == 11, f"Expected 11 columns, got {len(df.columns)}"
    assert list(df.columns) == expected_columns, (
        f"Column mismatch.\nExpected: {expected_columns}\nGot: {list(df.columns)}"
    )

    missing_count = df.isna().sum().sum()
    assert missing_count == 0, f"Missing values found: {missing_count} total NaNs"

    mkt_rf_mean = df["mkt_rf"].mean()
    assert -0.001 <= mkt_rf_mean <= 0.002, (
        f"Factor scale check failed: mkt_rf mean = {mkt_rf_mean:.6f}. "
        "Expected range [-0.001, 0.002]. "
        "If > 0.002, the Ken French % to decimal conversion was not applied."
    )

    assert 1_000 <= len(df) <= 1_400, (
        f"Unexpected row count: {len(df)}. "
        "Expected approximately 1,250 NYSE trading days for 2021-01-01 to 2025-12-31."
    )

    print("--- Validation Summary ---")
    print(f"  Rows       : {len(df)}")
    print(f"  Date range : {df['date'].iloc[0]} to {df['date'].iloc[-1]}")
    print(f"  mkt_rf mean: {mkt_rf_mean:.6f}")
    print(f"  Columns    : {list(df.columns)}")
    print(f"  NaN count  : {missing_count}")
    print("  All assertions PASSED")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    dataset = build_dataset()
    validate_dataset(dataset)
    dataset.to_csv(OUTPUT_PATH, index=False)
    print(f"Dataset written to {OUTPUT_PATH} ({len(dataset)} rows)")
