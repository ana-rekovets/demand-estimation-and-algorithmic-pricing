.PHONY: help verify report rerun-part2 rerun-part1 rerun-all clean deps

NB      := notebooks
REPORT  := report
RERUN   := build/rerun

help:
	@echo "Targets:"
	@echo "  make deps         Install Python dependencies"
	@echo "  make verify       Check every number in the report against notebook outputs (fast, no data)"
	@echo "  make report       Rebuild the PDF from the LaTeX source"
	@echo "  make rerun-part2  Re-execute Part 2 and confirm it reproduces the committed results (~40 min)"
	@echo "  make rerun-part1  Re-execute Part 1 (requires the Expedia parquet; see README)"
	@echo "  make rerun-all    Both re-runs, then verify and rebuild the report"

deps:
	pip install -r requirements.txt
	pip install nbclient nbformat ipykernel

# ---------------------------------------------------------------- fast check
# Reads only the committed notebook outputs and the LaTeX source. No dataset,
# no compute. This is what catches the report drifting away from the code.
verify:
	python3 scripts/check_report_matches_notebooks.py

report: verify
	cd $(REPORT) && pdflatex -interaction=nonstopmode Rekovets_Report.tex >/dev/null && \
	                pdflatex -interaction=nonstopmode Rekovets_Report.tex >/dev/null && \
	                rm -f *.aux *.log *.out *.toc
	@echo "rebuilt $(REPORT)/Rekovets_Report.pdf"

# ---------------------------------------------------------------- re-runs
# Part 2 is self-contained: pure numpy, seeded per run, no external data.
rerun-part2:
	@mkdir -p $(RERUN)
	cd $(RERUN) && python3 ../../scripts/execute_notebook.py \
	    ../../$(NB)/part2_algorithmic_pricing_qlearning.ipynb part2_rerun.ipynb
	python3 scripts/compare_notebook_results.py \
	    $(NB)/part2_algorithmic_pricing_qlearning.ipynb $(RERUN)/part2_rerun.ipynb

# Part 1 needs the Expedia dataset, which is not in this repository.
# Set EXPEDIA_PARQUET to the processed parquet before running.
rerun-part1:
	@if [ -z "$$EXPEDIA_PARQUET" ]; then \
	    echo "EXPEDIA_PARQUET is not set."; \
	    echo "Download the Kaggle dataset, build the parquet, then:"; \
	    echo "  EXPEDIA_PARQUET=/path/to/train_processed.parquet make rerun-part1"; \
	    exit 1; \
	fi
	@mkdir -p $(RERUN)
	cd $(RERUN) && python3 ../../scripts/execute_notebook.py \
	    ../../$(NB)/part1_hotel_demand_estimation.ipynb part1_rerun.ipynb
	python3 scripts/compare_notebook_results.py \
	    $(NB)/part1_hotel_demand_estimation.ipynb $(RERUN)/part1_rerun.ipynb

rerun-all: rerun-part2 rerun-part1 verify report

clean:
	rm -rf build
	cd $(REPORT) && rm -f *.aux *.log *.out *.toc
