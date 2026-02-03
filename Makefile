.PHONY: all data analysis report clean

all: data analysis report

data:
	python src/pipeline.py

analysis:
	Rscript src/analysis.R

report:
	typst compile report/main.typ main.pdf

clean:
	rm -rf data/processed/ outputs/
