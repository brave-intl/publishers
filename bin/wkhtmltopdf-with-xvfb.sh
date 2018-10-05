#!/bin/bash
xvfb-run -a -s "-screen 0 640x480x16" wkhtmltopdf "$@"
