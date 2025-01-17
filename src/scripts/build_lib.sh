#!/usr/bin/env bash
# Copyright (c) 2019 University of Exeter
#               2018-2019 University of Paris-Saclay
#               2018-2019 The University of Sheffield
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# SPDX-License-Identifier: BSD-2-Clause

OUTFORMAT=${1:-pdf}
NAME=${2:-root}

set -e

ROOT_NAME="root_$NAME"
[ ! -f "$DIR/$ROOT_NAME.tex" ] && ROOT_NAME="root"

if [ ! -f $ISABELLE_HOME_USER/DOF/document-template/DOF-core.sty ]; then
    >&2 echo ""
    >&2 echo "Error: Isabelle/DOF not installed"
    >&2 echo "====="
    >&2 echo "This is a Isabelle/DOF project. The document preparation requires"
    >&2 echo "the Isabelle/DOF framework. Please obtain the framework by cloning"
    >&2 echo "the Isabelle/DOF git repository, i.e.: "
    >&2 echo "    git clone <isadofurl>"
    >&2 echo "You can install the framework as follows:"
    >&2 echo "    cd Isabelle_DOF/document-generator"
    >&2 echo "    ./install"
    >&2 echo ""
    exit 1
fi

if [ -f "$DIR/$ROOT_NAME.tex" ]; then 
    >&2 echo ""
    >&2 echo "Error: Found root file ($DIR/$ROOT_NAME.tex)"
    >&2 echo "====="
    >&2 echo "Isabelle/DOF does not use the Isabelle root file setup. Please check"
    >&2 echo "your project setup. Your $DIR/isadof.cfg should define a Isabelle/DOF"
    >&2 echo "template and your project should not include a root file."
    >&2 echo ""
    exit 1
fi

if [ -f "$DIR/ontologies.tex" ]; then 
    >&2 echo ""
    >&2 echo "Error: Old project setup, found a ontologies file ($DIR/ontologies.tex)"
    >&2 echo "====="
    >&2 echo "Isabelle/DOF does no longer support the use of $DIR/ontologies.tex. The"
    >&2 echo "required ontologies should be defined in $DIR/isadof.cfg."
    >&2 echo ""
    exit 1
fi

if [ -f "$DIR/$ROOT_NAME.tex" ]; then 
    >&2 echo ""
    >&2 echo "Error: Found root file ($DIR/$ROOT_NAME.tex)"
    >&2 echo "====="
    >&2 echo "Isabelle/DOF does not make use of the Isabelle root file mechanism."
    >&2 echo "Please check your Isabelle/DOF setup."
    exit 1
fi

if [ ! -f isadof.cfg ]; then 
    >&2 echo ""
    >&2 echo "Error: Isabelle/DOF document setup not correct"
    >&2 echo "====="
    >&2 echo "Could not find isadof.cfg. Please upgrade your Isabelle/DOF document"
    >&2 echo "setup manually."
    exit 1
fi

TEMPLATE=""
ONTOLOGY="core"
CONFIG="isadof.cfg"
while IFS= read -r line;do
    fields=($(printf "%s" "$line"|cut -d':' -f1- | tr ':' ' '))
    if [[ "${fields[0]}" = "Template" ]]; then 
	TEMPLATE="${fields[1]}"
    fi                      
    if [[ "${fields[0]}" = "Ontology" ]]; then 
	ONTOLOGY="$ONTOLOGY ${fields[1]}"
    fi
done < $CONFIG

for o in $ONTOLOGY; do
  >&2 echo "\usepackage{DOF-$o}" >> ontologies.tex;
done

ROOT="$ISABELLE_HOME_USER/DOF/document-template/root-$TEMPLATE.tex"
if [ ! -f $ROOT ]; then 
    >&2 echo ""
    >&2 echo "Error: Isabelle/DOF document setup not correct"
    >&2 echo "====="
    >&2 echo "Could not find root file ($ROOT)."
    >&2 echo "Please upgrade your Isabelle/DOF document setup manually."
    exit 1
fi

cp $ROOT root.tex
cp $ISABELLE_HOME_USER/DOF/latex/*.sty .
cp $ISABELLE_HOME_USER/DOF/document-template/*.sty .

# delete outdated aux files from previous runs
rm -f *.aux 

sed -i -e 's/<@>/@/g' *.tex 

$ISABELLE_PDFLATEX root && \
{ [ ! -f "$ROOT_NAME.bib" ] || $ISABELLE_BIBTEX root; } && \
{ [ ! -f "$ROOT_NAME.idx" ] || $ISABELLE_MAKEINDEX root; } && \
$ISABELLE_PDFLATEX root && \
$ISABELLE_PDFLATEX root

MISSING_CITATIONS=`grep 'Warning.*Citation' root.log | awk '{print $5}' | sort  -u`
if [ "$MISSING_CITATIONS" != "" ]; then
    >&2 echo ""
    >&2 echo "ERROR (Isabelle/DOF): document referencing inconsistent due to missing citations: "
    >&2 echo "$MISSING_CITATIONS"
    exit 1
fi
DANGLING_REFS=`grep 'Warning.*Refer' root.log | awk '{print $4}' | sort  -u`
if [ "$DANGLING_REFS" != "" ]; then
    >&2 echo ""
    >&2 echo "ERROR (Isabelle/DOF): document referencing inconsistent due to dangling references:"
    >&2 echo "$DANGLING_REFS"
    >&2 echo ""
    exit 1
fi
if [ -f "root.blg" ]; then 
    >&2 echo "BibTeX Warnings:"
    >&2 echo "================"
    >&2 grep Warning  root.blg | sed -e 's/Warning--//'
    >&2 echo ""
fi
>&2 echo "Layout Glitches:"
>&2 echo "================"
>&2 echo -n "Number of overfull hboxes: "
>&2 grep 'Overfull .hbox' root.log | wc -l
>&2 echo -n "Number of underfull hboxes: "
>&2 grep 'Underfull .hbox' root.log | wc -l
>&2 echo -n "Number of overfull vboxes: "
grep 'Overfull .vbox' root.log | wc -l
>&2 echo -n "Number of underfull vboxes: "
grep 'Underfull .vbox' root.log | wc -l
>&2 echo ""

exit 0
