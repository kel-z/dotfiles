# Global instructions

## Handling PDF files

Models are configured with text+image input only — if the `read` tool fails on a PDF with
"this model does not support pdf input", use the CLI workflow below instead
(Poppler tools from Homebrew, all on PATH: `pdftotext`, `pdftoppm`, `pdfinfo`,
`pdfseparate`, `pdfunite`, `pdfimages`).

- **Text extraction (default choice):**
  `pdftotext -layout "file.pdf" out.txt`
  Then `read` the `.txt` file. Omit `-layout` for reflowed reading-order text.
  Use `pdftotext -f 1 -l 5` to limit to a page range.
- **Visual/layout feedback (formatting, design, images, charts):** render pages to PNG and
  read the image instead (image reading IS supported):
  `pdftoppm -png -r 150 -f 1 -l 3 "file.pdf" page`
  → writes `page-01.png`, `page-02.png`, ... in the current directory.
  Use `-r 200+` for small text; add `-scale-to 2000` for a fixed pixel height.
- **Metadata / page count:** `pdfinfo "file.pdf"` (check page count and encryption before
  processing large or suspicious files).
- **Manipulation:** `pdfunite in1.pdf in2.pdf out.pdf` (merge),
  `pdfseparate "file.pdf" page-%d.pdf` (split), `pdfimages -png "file.pdf" img` (extract images).
  For rotation/encryption-level edits install qpdf (`brew install qpdf`).
- A `pdf` skill is available — load it with the `skill` tool for tables, PDF creation,
  and richer manipulation examples.
- Scanned/image-only PDFs produce empty text — that means they need OCR; say so rather
  than guessing content.
- If Poppler tools are missing, install with `brew install poppler`.
