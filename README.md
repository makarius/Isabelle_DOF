# Isabelle/DOF: Document Preparation Setup

Isabelle/DOF is a novel Document Ontology Framework on top of
Isabelle. Isabelle/DOF allows for both conventional typesetting as
well as formal development.

## Pre-requisites

Isabelle/DOF has two major pre-requisites:

* **Isabelle:** Isabelle/DOF requires [Isabelle 2019](http://isabelle.in.tum.de/website-Isabelle2019/).
  Please download the Isabelle 2019 distribution for your operating
  system from the [Isabelle website](http://isabelle.in.tum.de/website-Isabelle2019/).
* **LaTeX:** Isabelle/DOF requires a modern pdfTeX-engine supporting the \expanded{}-primitive. This
  is, for example, included in the [TeXLive 2019](https://www.tug.org/texlive/) (or later)
  distribution. Please follow the [TeXLive installation instructions](https://www.tug.org/texlive/acquire-netinstall.html)
  for installing TeXLive.

## Installation

### Quick Installation Guide

In most case, the DOF-plugin can be installed as follows:

```console
foo@bar:~$ ./install
```

If a specific Isabelle version should be used (i.e., not the default
one), the full path to the ``isabelle`` command needs to be passed as
using the ``--isabelle`` command line argument of the ``install`` script:

```console
foo@bar:~$ ./install --isabelle /usr/local/Isabelle2019/bin/isabelle
```

For further command line options of the installer, please use the
built-in help:

```console
foo@bar:~$ ./install --help
```

### What The Installer Actually Does

The installer will

* apply a patch to Isabelle that is necessary to use Isabelle/DOF.
  If this patch installations fails, you need to manually replace
  the file ``Isabelle2019/src/Pure/Thy/thy_output.ML`` in the Isabelle
  distribution with the file ``src/patches/thy_output.ML`` from the  
  Isabelle/DOF distribution:

        cp patches/thy_output.ML `isabelle getenv -b ISABELLE_HOME`/src/Pure/Thy/

* install required entries from the [AFP](https://www.isa-afp.org). If this
  installations fails, you need to manually install the AFP for Isabelle 2019 as follows:
  Download the [AFP for Isabelle 2019](https://www.isa-afp.org/release/afp-2019-06-17.tar.gz)
  and follow the [instructions for installing the AFP as Isabelle 
  component](https://www.isa-afp.org/using.html). If you have extracted
  the AFP archive into the directory to `/home/myself/afp`, you should
  run the following command to make the AFP session `ROOTS` available to
  Isabelle:

        echo "/home/myself/afp/thys" >> ~/.isabelle/Isabelle2019/ROOTS

* registers Isabelle/DOF as Isabelle component

* install the Isabelle/DOF-plugin into the Isabelle user directory
  (the exact location depends on the Isabelle version).
* check that the AFP has been installed successfully.

## Usage

### Opening an Example

If you want to work with or extend one of the examples, e.g., you can
open it similar to any standard Isabelle theory:

```console
isabelle jedit -d . -l Isabelle_DOF examples/scholarly_paper/2018_cicm/IsaDofApplications.thy
```

This will open an example of a scientific paper using the pre-compiled
session ``Isabelle_DOF``, i.e., you will not be able to edit the
ontology definitions. If you want to edit the ontology definition,
just open the theory file with the default HOL session:

```console
isabelle jedit -d . -l HOL examples/scholarly_paper/2018_cicm/IsaDofApplications.thy
```

While this gives you more flexibility, it might "clutter" your editing
experience, as a lot of internal theories are loaded into Isabelle's
editor.

### Creating a New Project

The DOF-plugin provides an alternative to Isabelle's ``mkroot`` command.
Isabelle projects that use DOF need to be created using
```console 
foo@bar:~$ isabelle mkroot_DOF
```
The ``mkroot_DOF`` command takes the same parameter as the standard
``mkroot`` command of Isabelle. Thereafter, the normal Isabelle
command for building documents can be used.

Using the ``-o`` option, different ontology setups can be
selected and using the ``-t`` option, different LaTeX setups 
can be selected (use ``-h`` to obtain a list of all installed setups):
```console 
foo@bar:~$ isabelle mkroot_DOF -h

Usage: isabelle mkroot_DOF [OPTIONS] [DIR]

  Options are:
    -h           print this help text and exit
    -n NAME      alternative session name (default: DIR base name)
    -o ONTOLOGY  (default: scholarly_paper)
       Available ontologies:
       * cenelec_50128
       * core
       * mathex
       * scholarly_paper
    -t TEMPLATE   (default: scrartcl)
       Available document templates:
       * lncs
       * scrartcl
       * scrreprt
       * scrreprt-modern

  Prepare session root DIR (default: current directory).
```
For example,
```console 
foo@bar:~$ isabelle mkroot_DOF -o scholarly_paper -t scrartcl
```
creates a setup using the scholarly_paper ontology and the article
class from the KOMA-Script bundle.

## Team

Main contacts:

* [Achim D. Brucker](http://www.brucker.ch/)
* [Burkhart Wolff](https://www.lri.fr/~wolff/)

### Contributors

* Idir Ait-Sadoune
* Paolo Crisafulli
* Chantal Keller

## License

This project is licensed under a 2-clause BSD license.

SPDX-License-Identifier: BSD-2-Clause

## Publications

* Achim D. Brucker, Idir Ait-Sadoune, Paolo Crisafulli, and Burkhart
  Wolff. [Using The Isabelle Ontology Framework: Linking the Formal
  with the Informal](https://www.brucker.ch/bibliography/download/2018/brucker.ea-isabelle-ontologies-2018.pdf).
  In Conference on Intelligent Computer Mathematics (CICM). Lecture
  Notes in Computer Science (11006), Springer-Verlag, 2018.

* Achim D. Brucker and Burkhart Wolff. [Isabelle/DOF: Design and
  Implementation](https://www.brucker.ch/bibliography/download/2019/brucker.ea-isabelledof-2019.pdf).
  In Software Engineering and Formal Methods (SEFM). Lecture Notes in
  Computer Science, Springer-Verlag, 2019.

## Master Repository

The master git repository for this project is hosted 
<https://git.logicalhacking.com/Isabelle_DOF/Isabelle_DOF>.

