30-Aug-2026
release: fasta_www_rel-0.1.7 -- fixes for annotations on blast output

29-Aug-2026
release: fasta_www3_rel-0.1.6 -- more robust input/output filters
release: fasta_www3_rel-0.1.5a -- bug patch for plot_domain7.cgi
release: fasta_www3_rel-0.1.5 -- bug patch for plot_domain7.cgi

29-Aug-2026

release: fasta_www3_rel-0.1.4 -- removal of system() calls that include user input

16-Aug-2026

release: fasta_www3_rel-0.1.1 -- use back_tick() function rather than '`' for
webserver safety

This package of perl scripts implements the current FASTA WWW site.

**The scripts are:**

| File | Description |
| :--- | :--- |
| fasta_www.cgi |  the main program that listens for commands |
| FASTA_WWW.pm |  the CGI::Application perl module that provides the functions that implement the different commands (run-modes)  |
| tmp_gs.cgi |  a script for converting post-script to png or pdf for images |
| select.tmpl |  template files for the different "forms" that |
| compare.tmpl |	  the user to select the program, sequence, library |
| misc1.tmpl   |	  (or second sequence) and parameters |
| fawww_defs.pl |  a machine-specific configuration file that specifies where programs and databases are found |
| fawww_libs.pl |  configuration file that lists programs and database selections |
| fawww_pgms.pl |  configuration file for do_form() and search3() options |
| fawww_pgm_text.pl | text descritions for menu pages |

Perl CPAN modules used:

| Module | Purpose |
| :--- | :--- |
| File::Temp |  create temporary files for compare 2 sequences, shuffles
| CGI::Application | central to the entire system
| CGI::Session	 | allows status of searches to be tracked
| CGI::Application::Plugin::Session   | required with CGI::Session
| IPC::Run |  used for running programs, capturing stdout, stderr
| IO::Scalar |  reading from strings
| HTTP::Request	 | for remote searching
| HTML::Template   |
| HTML::Entities	 | prevent cross-site scripting
| HTML::FillInForm |  helps preserve arguments
| LWP::UserAgent |  required for remote searching in a cluster
| LWP::Simple |  used to get sequences from NCBI
| Text::ParseWords | re-encode command line argument
| JSON            | save/transmit parameters as JSON

**Helper programs required:**

| Program | Purpose |
| :--- | :--- |
| ghostview (gs) |  required for plots of local alignments (plalign) and of Kyte-Doolittle hydropathy.  Used by tmp_png.cgi, and fasta_www.cgi rm=misc1 pgm=pkd to convert ps to PDF and PNG (tmp_png.cgi)

| fastacmd |  used to get sequences locally when they are available.  |
| 	 | fastacmd can read a local copy of the NCBI nr  protein library.  The code has not been tested with local DNA nt library. |

**Other files required:**

| File | Description |
| :--- | :--- |
| fast_libs.www |  a FASTLIBS file (see FASTA documentation) that lists the databases available: their names and locations |
| fast_gnms.www |  a FASTLIBS for genome databases FASTA sequence analysis programs required: |

**Programs from the fasta36 distribution:**

https://github.com/wrpearson/fasta36

`fasta36 (fastx36 fasty36 tfastx36 tfasty36 fasts36 tfasts36 fastf36 tfastf36)`
`ssearch36`

Programs from the fasta2 distribution:
https://fasta.bioch.virginia.edu/wrpearson/fasta/fasta2.shar.Z

`psgrease`
`chofas`, `garnier`

The `pseg` program  ftp://ftp.ncbi.nih.gov/pub/seg/pseg

---
Instructions for setting up/configuration -- see INSTALL in this directory
---
