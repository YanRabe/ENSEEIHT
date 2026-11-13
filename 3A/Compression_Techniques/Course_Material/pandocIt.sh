for f in CSIV_Exam_Course CSIV_Predicted_Quiz; do
  pandoc "$f.md" -o "$f.pdf" \
    --pdf-engine=xelatex \
    --toc --toc-depth=2 \
    -H csiv-style.tex \
    -V documentclass=article -V fontsize=10pt -V linestretch=1.02 \
    -V colorlinks=true -V papersize=a4 -V geometry:margin=1.75cm -V lang=fr \
    --resource-path=. --highlight-style=tango
done