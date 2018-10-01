#!/bin/bash
xvfb-run -a -s "-screen 0 640x480x16" /usr/bin/wkhtmltopdf "$@"
# exec xvfb-run -a -s "-screen 0 640x480x16" /usr/bin/wkhtmltopdf "$@" # https://github.com/mileszs/wicked_pdf/issues/214#issuecomment-244415458
