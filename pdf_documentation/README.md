# Generating PDF documents

## Developer Documentation

Install [asciidoctor-pdf](https://asciidoctor.org/docs/asciidoctor-pdf/)

Then run :

    cd pdf_documentation
    # Copy any images from the public dir:
    cp ../public/documentation_images/* .
    asciidoctor-pdf developer_documentation.adoc

To use dark-styled syntax, run:

    asciidoctor-pdf -a rouge-style=monokai developer_documentation.adoc

