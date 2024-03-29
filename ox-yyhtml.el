;;; ox-yyhtml.el --- yet another HTML Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2011-2022 Free Software Foundation, Inc.

;; Author: Carsten Dominik <carsten.dominik@gmail.com>
;;      Jambunathan K <kjambunathan at gmail dot com>
;; Maintainer: TEC <tecosaur@gmail.com>
;; Keywords: outlines, hypermedia, calendar, wp

;; This file is not part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a HTML back-end for Org generic exporter.
;; See Org manual for more information.

;; do some improvement for me.
;; 2023-06-13 include-yy
;; M-s o <yynt> to see modifications
;;; Code:

;;; Dependencies

(require 'cl-lib)
(require 'format-spec)
(require 'ox)
(require 'ox-publish)
(require 'table)


;;; Function Declarations

(declare-function org-id-find-id-file "org-id" (id))
(declare-function htmlize-region "ext:htmlize" (beg end))
(declare-function mm-url-decode-entities "mm-url" ())

(defvar htmlize-css-name-prefix)
(defvar htmlize-output-type)
(defvar htmlize-output-type)
(defvar htmlize-css-name-prefix)

;;; Define Back-End

(org-export-define-backend 'yyhtml
  '((bold . t-bold)
    (center-block . t-center-block)
    (clock . t-clock)
    (code . t-code)
    (drawer . t-drawer)
    (dynamic-block . t-dynamic-block)
    (entity . t-entity)
    (example-block . t-example-block)
    (export-block . t-export-block)
    (export-snippet . t-export-snippet)
    (fixed-width . t-fixed-width)
    (footnote-reference . t-footnote-reference)
    (headline . t-headline)
    (horizontal-rule . t-horizontal-rule)
    (inline-src-block . t-inline-src-block)
    (inlinetask . t-inlinetask)
    (inner-template . t-inner-template)
    (italic . t-italic)
    (item . t-item)
    (keyword . t-keyword)
    (latex-environment . t-latex-environment)
    (latex-fragment . t-latex-fragment)
    (line-break . t-line-break)
    (link . t-link)
    (node-property . t-node-property)
    (paragraph . t-paragraph)
    (plain-list . t-plain-list)
    (plain-text . t-plain-text)
    (planning . t-planning)
    (property-drawer . t-property-drawer)
    (quote-block . t-quote-block)
    (radio-target . t-radio-target)
    (section . t-section)
    (special-block . t-special-block)
    (src-block . t-src-block)
    (statistics-cookie . t-statistics-cookie)
    (strike-through . t-strike-through)
    (subscript . t-subscript)
    (superscript . t-superscript)
    (table . t-table)
    (table-cell . t-table-cell)
    (table-row . t-table-row)
    (target . t-target)
    (template . t-template)
    (timestamp . t-timestamp)
    (underline . t-underline)
    (verbatim . t-verbatim)
    (verse-block . t-verse-block))
  :filters-alist '((:filter-options . t-infojs-install-script)
		   (:filter-parse-tree . t-image-link-filter)
		   (:filter-final-output . t-final-function))
  :menu-entry
  '(?y "Export to yyHTML"
       ((?H "As HTML buffer" t-export-as-html)
	(?y "As HTML file" t-export-to-html)
	(?o "As HTML file and open"
	    (lambda (a s v b)
	      (if a (t-export-to-html t s v b)
		(org-open-file (t-export-to-html nil s v b)))))))
  :options-alist
  '((:html-doctype "HTML_DOCTYPE" nil t-doctype)
    (:html-container "HTML_CONTAINER" nil t-container-element)
    (:html-content-class "HTML_CONTENT_CLASS" nil t-content-class)
    (:description "DESCRIPTION" nil nil newline)
    (:keywords "KEYWORDS" nil nil space)
    (:html-html5-fancy nil "html5-fancy" t-html5-fancy)
    (:html-link-use-abs-url nil "html-link-use-abs-url" t-link-use-abs-url)
    (:html-link-home "HTML_LINK_HOME" nil t-link-home)
    (:html-link-up "HTML_LINK_UP" nil t-link-up)
    (:html-mathjax "HTML_MATHJAX" nil "" space)
    (:html-equation-reference-format "HTML_EQUATION_REFERENCE_FORMAT" nil t-equation-reference-format t)
    (:html-postamble nil "html-postamble" t-postamble)
    (:html-preamble nil "html-preamble" t-preamble)
    (:html-head "HTML_HEAD" nil t-head newline)
    (:html-head-extra "HTML_HEAD_EXTRA" nil t-head-extra newline)
    (:subtitle "SUBTITLE" nil nil parse)
    (:html-head-include-default-style
     nil "html-style" t-head-include-default-style)
    (:html-head-include-scripts nil "html-scripts" t-head-include-scripts)
    (:html-allow-name-attribute-in-anchors
     nil nil t-allow-name-attribute-in-anchors)
    (:html-divs nil nil t-divs)
    (:html-checkbox-type nil nil t-checkbox-type)
    (:html-extension nil nil t-extension)
    (:html-footnote-format nil nil t-footnote-format)
    (:html-footnote-separator nil nil t-footnote-separator)
    (:html-footnotes-section nil nil t-footnotes-section)
    (:html-format-drawer-function nil nil t-format-drawer-function)
    (:html-format-headline-function nil nil t-format-headline-function)
    (:html-format-inlinetask-function
     nil nil t-format-inlinetask-function)
    (:html-home/up-format nil nil t-home/up-format)
    (:html-indent nil nil t-indent)
    (:html-infojs-options nil nil t-infojs-options)
    (:html-infojs-template nil nil t-infojs-template)
    (:html-inline-image-rules nil nil t-inline-image-rules)
    (:html-link-org-files-as-html nil nil t-link-org-files-as-html)
    (:html-mathjax-options nil nil t-mathjax-options)
    (:html-mathjax-template nil nil t-mathjax-template)
    (:html-metadata-timestamp-format nil nil t-metadata-timestamp-format)
    (:html-postamble-format nil nil t-postamble-format)
    (:html-preamble-format nil nil t-preamble-format)
    (:html-prefer-user-labels nil nil t-prefer-user-labels)
    (:html-self-link-headlines nil nil t-self-link-headlines)
    (:html-table-align-individual-fields
     nil nil t-table-align-individual-fields)
    (:html-table-caption-above nil nil t-table-caption-above)
    (:html-table-data-tags nil nil t-table-data-tags)
    (:html-table-header-tags nil nil t-table-header-tags)
    (:html-table-use-header-tags-for-first-column
     nil nil t-table-use-header-tags-for-first-column)
    (:html-tag-class-prefix nil nil t-tag-class-prefix)
    (:html-text-markup-alist nil nil t-text-markup-alist)
    (:html-todo-kwd-class-prefix nil nil t-todo-kwd-class-prefix)
    (:html-toplevel-hlevel nil nil t-toplevel-hlevel)
    (:html-use-infojs nil nil t-use-infojs)
    (:html-validation-link nil nil t-validation-link)
    (:html-viewport nil nil t-viewport)
    (:html-inline-images nil nil t-inline-images)
    (:html-table-attributes nil nil t-table-default-attributes)
    (:html-table-row-open-tag nil nil t-table-row-open-tag)
    (:html-table-row-close-tag nil nil t-table-row-close-tag)
    (:html-xml-declaration nil nil t-xml-declaration)
    (:html-wrap-src-lines nil nil t-wrap-src-lines)
    (:html-klipsify-src nil nil t-klipsify-src)
    (:html-klipse-css nil nil t-klipse-css)
    (:html-klipse-js nil nil t-klipse-js)
    (:html-klipse-selection-script nil nil t-klipse-selection-script)
    (:infojs-opt "INFOJS_OPT" nil nil)
    ;; Redefine regular options.
    (:creator "CREATOR" nil t-creator-string)
    (:with-latex nil "tex" t-with-latex)
    ;; Retrieve LaTeX header for fragments.
    (:latex-header "LATEX_HEADER" nil nil newline)
    ;;; <yynt> options added by include-yy
    (:html-head-func "HTML_HEAD_FUNC" nil nil)
    (:html-new-preamble-func "HTML_PREFUNC" nil nil)
    (:html-new-preamble "HTML_PRE" nil "" newline)
    (:html-new-postamble-func "HTML_SUFFUNC" nil nil)
    (:html-new-postamble "HTML_SUF" nil nil newline)
    (:html-link-left "HTML_LINK_LEFT" nil t-link-up)
    (:html-link-lname "HTML_LINK_LNAME" nil "UP")
    (:html-link-right "HTML_LINK_RIGHT" nil t-link-home)
    (:html-link-rname "HTML_LINK_RNAME" nil "HOME")
    (:html-link-func "HTML_LINK_FUNC" nil nil)
    (:html-headline-cnt nil nil 0)))


;;; Internal Variables

(defvar t-format-table-no-css)
(defvar htmlize-buffer-places)  ; from htmlize.el

(defvar t--pre/postamble-class "status"
  "CSS class used for pre/postamble.")

(defconst t-doctype-alist
  '(("html4-strict" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\"
\"http://www.w3.org/TR/html4/strict.dtd\">")
    ("html4-transitional" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
\"http://www.w3.org/TR/html4/loose.dtd\">")
    ("html4-frameset" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\"
\"http://www.w3.org/TR/html4/frameset.dtd\">")

    ("xhtml-strict" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">")
    ("xhtml-transitional" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
    ("xhtml-frameset" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">")
    ("xhtml-11" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml11.dtd\">")

    ("html5" . "<!DOCTYPE html>")
    ("xhtml5" . "<!DOCTYPE html>"))
  "An alist mapping (x)html flavors to specific doctypes.")

(defconst t-html5-elements
  '("article" "aside" "audio" "canvas" "details" "figcaption" "div" ;; <yynt> 添加空 div 标签
    "figure" "footer" "header" "menu" "meter" "nav" "noscript" ;; <yynt> 添加 noscript 标签
    "output" "progress" "section" "summary" "video")
  "New elements in html5.

For blocks that should contain headlines, use the HTML_CONTAINER
property on the headline itself.")

(defconst t-special-string-regexps
  '(("\\\\-" . "&#x00ad;")		; shy
    ("---\\([^-]\\)" . "&#x2014;\\1")	; mdash
    ("--\\([^-]\\)" . "&#x2013;\\1")	; ndash
    ("\\.\\.\\." . "&#x2026;"))		; hellip
  "Regular expressions for special string conversion.")

(defcustom t-scripts
  "<script>
// @license magnet:?xt=urn:btih:1f739d935676111cfff4b4693e3816e664797050&amp;dn=gpl-3.0.txt GPL-v3-or-Later
     function CodeHighlightOn(elem, id)
     {
       var target = document.getElementById(id);
       if(null != target) {
         elem.classList.add(\"code-highlighted\");
         target.classList.add(\"code-highlighted\");
       }
     }
     function CodeHighlightOff(elem, id)
     {
       var target = document.getElementById(id);
       if(null != target) {
         elem.classList.remove(\"code-highlighted\");
         target.classList.remove(\"code-highlighted\");
       }
     }
// @license-end
</script>"
  "Basic JavaScript to allow highlighting references in code blocks."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.5")
  :type 'string)

(defcustom t-style-default
  "<style>
  #content { max-width: 60em; margin: auto; }
  .title  { text-align: center;
             margin-bottom: .2em; }
  .subtitle { text-align: center;
              font-size: medium;
              font-weight: bold;
              margin-top:0; }
  .todo   { font-family: monospace; color: red; }
  .done   { font-family: monospace; color: green; }
  .priority { font-family: monospace; color: orange; }
  .tag    { background-color: #eee; font-family: monospace;
            padding: 2px; font-size: 80%; font-weight: normal; }
  .timestamp { color: #bebebe; }
  .timestamp-kwd { color: #5f9ea0; }
  .org-right  { margin-left: auto; margin-right: 0px;  text-align: right; }
  .org-left   { margin-left: 0px;  margin-right: auto; text-align: left; }
  .org-center { margin-left: auto; margin-right: auto; text-align: center; }
  .underline { text-decoration: underline; }
  #postamble p, #preamble p { font-size: 90%; margin: .2em; }
  p.verse { margin-left: 3%; }
  pre {
    border: 1px solid #e6e6e6;
    border-radius: 3px;
    background-color: #f2f2f2;
    padding: 8pt;
    font-family: monospace;
    overflow: auto;
    margin: 1.2em;
  }
  pre.src {
    position: relative;
    overflow: auto;
  }
  pre.src:before {
    display: none;
    position: absolute;
    top: -8px;
    right: 12px;
    padding: 3px;
    color: #555;
    background-color: #f2f2f299;
  }
  pre.src:hover:before { display: inline; margin-top: 14px;}
  /* Languages per Org manual */
  pre.src-asymptote:before { content: 'Asymptote'; }
  pre.src-awk:before { content: 'Awk'; }
  pre.src-authinfo::before { content: 'Authinfo'; }
  pre.src-C:before { content: 'C'; }
  /* pre.src-C++ doesn't work in CSS */
  pre.src-clojure:before { content: 'Clojure'; }
  pre.src-css:before { content: 'CSS'; }
  pre.src-D:before { content: 'D'; }
  pre.src-ditaa:before { content: 'ditaa'; }
  pre.src-dot:before { content: 'Graphviz'; }
  pre.src-calc:before { content: 'Emacs Calc'; }
  pre.src-emacs-lisp:before { content: 'Emacs Lisp'; }
  pre.src-fortran:before { content: 'Fortran'; }
  pre.src-gnuplot:before { content: 'gnuplot'; }
  pre.src-haskell:before { content: 'Haskell'; }
  pre.src-hledger:before { content: 'hledger'; }
  pre.src-java:before { content: 'Java'; }
  pre.src-js:before { content: 'Javascript'; }
  pre.src-latex:before { content: 'LaTeX'; }
  pre.src-ledger:before { content: 'Ledger'; }
  pre.src-lisp:before { content: 'Lisp'; }
  pre.src-lilypond:before { content: 'Lilypond'; }
  pre.src-lua:before { content: 'Lua'; }
  pre.src-matlab:before { content: 'MATLAB'; }
  pre.src-mscgen:before { content: 'Mscgen'; }
  pre.src-ocaml:before { content: 'Objective Caml'; }
  pre.src-octave:before { content: 'Octave'; }
  pre.src-org:before { content: 'Org mode'; }
  pre.src-oz:before { content: 'OZ'; }
  pre.src-plantuml:before { content: 'Plantuml'; }
  pre.src-processing:before { content: 'Processing.js'; }
  pre.src-python:before { content: 'Python'; }
  pre.src-R:before { content: 'R'; }
  pre.src-ruby:before { content: 'Ruby'; }
  pre.src-sass:before { content: 'Sass'; }
  pre.src-scheme:before { content: 'Scheme'; }
  pre.src-screen:before { content: 'Gnu Screen'; }
  pre.src-sed:before { content: 'Sed'; }
  pre.src-sh:before { content: 'shell'; }
  pre.src-sql:before { content: 'SQL'; }
  pre.src-sqlite:before { content: 'SQLite'; }
  /* additional languages in org.el's org-babel-load-languages alist */
  pre.src-forth:before { content: 'Forth'; }
  pre.src-io:before { content: 'IO'; }
  pre.src-J:before { content: 'J'; }
  pre.src-makefile:before { content: 'Makefile'; }
  pre.src-maxima:before { content: 'Maxima'; }
  pre.src-perl:before { content: 'Perl'; }
  pre.src-picolisp:before { content: 'Pico Lisp'; }
  pre.src-scala:before { content: 'Scala'; }
  pre.src-shell:before { content: 'Shell Script'; }
  pre.src-ebnf2ps:before { content: 'ebfn2ps'; }
  /* additional language identifiers per \"defun org-babel-execute\"
       in ob-*.el */
  pre.src-cpp:before  { content: 'C++'; }
  pre.src-abc:before  { content: 'ABC'; }
  pre.src-coq:before  { content: 'Coq'; }
  pre.src-groovy:before  { content: 'Groovy'; }
  /* additional language identifiers from org-babel-shell-names in
     ob-shell.el: ob-shell is the only babel language using a lambda to put
     the execution function name together. */
  pre.src-bash:before  { content: 'bash'; }
  pre.src-csh:before  { content: 'csh'; }
  pre.src-ash:before  { content: 'ash'; }
  pre.src-dash:before  { content: 'dash'; }
  pre.src-ksh:before  { content: 'ksh'; }
  pre.src-mksh:before  { content: 'mksh'; }
  pre.src-posh:before  { content: 'posh'; }
  /* Additional Emacs modes also supported by the LaTeX listings package */
  pre.src-ada:before { content: 'Ada'; }
  pre.src-asm:before { content: 'Assembler'; }
  pre.src-caml:before { content: 'Caml'; }
  pre.src-delphi:before { content: 'Delphi'; }
  pre.src-html:before { content: 'HTML'; }
  pre.src-idl:before { content: 'IDL'; }
  pre.src-mercury:before { content: 'Mercury'; }
  pre.src-metapost:before { content: 'MetaPost'; }
  pre.src-modula-2:before { content: 'Modula-2'; }
  pre.src-pascal:before { content: 'Pascal'; }
  pre.src-ps:before { content: 'PostScript'; }
  pre.src-prolog:before { content: 'Prolog'; }
  pre.src-simula:before { content: 'Simula'; }
  pre.src-tcl:before { content: 'tcl'; }
  pre.src-tex:before { content: 'TeX'; }
  pre.src-plain-tex:before { content: 'Plain TeX'; }
  pre.src-verilog:before { content: 'Verilog'; }
  pre.src-vhdl:before { content: 'VHDL'; }
  pre.src-xml:before { content: 'XML'; }
  pre.src-nxml:before { content: 'XML'; }
  /* add a generic configuration mode; LaTeX export needs an additional
     (add-to-list 'org-latex-listings-langs '(conf \" \")) in .emacs */
  pre.src-conf:before { content: 'Configuration File'; }

  table { border-collapse:collapse; }
  caption.t-above { caption-side: top; }
  caption.t-bottom { caption-side: bottom; }
  td, th { vertical-align:top;  }
  th.org-right  { text-align: center;  }
  th.org-left   { text-align: center;   }
  th.org-center { text-align: center; }
  td.org-right  { text-align: right;  }
  td.org-left   { text-align: left;   }
  td.org-center { text-align: center; }
  dt { font-weight: bold; }
  .footpara { display: inline; }
  .footdef  { margin-bottom: 1em; }
  .figure { padding: 1em; }
  .figure p { text-align: center; }
  .equation-container {
    display: table;
    text-align: center;
    width: 100%;
  }
  .equation {
    vertical-align: middle;
  }
  .equation-label {
    display: table-cell;
    text-align: right;
    vertical-align: middle;
  }
  .inlinetask {
    padding: 10px;
    border: 2px solid gray;
    margin: 10px;
    background: #ffffcc;
  }
  #org-div-home-and-up
   { text-align: right; font-size: 70%; white-space: nowrap; }
  textarea { overflow-x: auto; }
  .linenr { font-size: smaller }
  .code-highlighted { background-color: #ffff00; }
  .org-info-js_info-navigation { border-style: none; }
  #org-info-js_console-label
    { font-size: 10px; font-weight: bold; white-space: nowrap; }
  .org-info-js_search-highlight
    { background-color: #ffff00; color: #000000; font-weight: bold; }
  .org-svg { }
</style>"
  "The default style specification for exported HTML files.
You can use `t-head' and `t-head-extra' to add to
this style.  If you don't want to include this default style,
customize `t-head-include-default-style'."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.5")
  :type 'string)


;;; User Configuration Variables

(defgroup org-export-yyhtml nil
  "Options for exporting Org mode files to HTML."
  :tag "Org Export HTML"
  :group 'org-export)

;;;; Handle infojs

(defvar t-infojs-opts-table
  '((path PATH "https://orgmode.org/org-info.js")
    (view VIEW "info")
    (toc TOC :with-toc)
    (ftoc FIXED_TOC "0")
    (tdepth TOC_DEPTH "max")
    (sdepth SECTION_DEPTH "max")
    (mouse MOUSE_HINT "underline")
    (buttons VIEW_BUTTONS "0")
    (ltoc LOCAL_TOC "1")
    (up LINK_UP :html-link-up)
    (home LINK_HOME :html-link-home))
  "JavaScript options, long form for script, default values.")

(defcustom t-use-infojs nil ;<yynt> 不使用 infojs
  "Non-nil when Sebastian Rose's Java Script org-info.js should be active.
This option can be nil or t to never or always use the script.
It can also be the symbol `when-configured', meaning that the
script will be linked into the export file if and only if there
is a \"#+INFOJS_OPT:\" line in the buffer.  See also the variable
`t-infojs-options'."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(choice
	  (const :tag "Never" nil)
	  (const :tag "When configured in buffer" when-configured)
	  (const :tag "Always" t)))

(defcustom t-infojs-options
  (mapcar (lambda (x) (cons (car x) (nth 2 x))) t-infojs-opts-table)
  "Options settings for the INFOJS JavaScript.
Each of the options must have an entry in `t-infojs-opts-table'.
The value can either be a string that will be passed to the script, or
a property.  This property is then assumed to be a property that is defined
by the Export/Publishing setup of Org.
The `sdepth' and `tdepth' parameters can also be set to \"max\", which
means to use the maximum value consistent with other options."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type
  `(set :greedy t :inline t
	,@(mapcar
	   (lambda (x)
	     (list 'cons (list 'const (car x))
		   '(choice
		     (symbol :tag "Publishing/Export property")
		     (string :tag "Value"))))
	   t-infojs-opts-table)))

(defcustom t-infojs-template
  "<script src=\"%SCRIPT_PATH\">
// @license magnet:?xt=urn:btih:1f739d935676111cfff4b4693e3816e664797050&amp;dn=gpl-3.0.txt GPL-v3-or-Later
// @license-end
</script>

<script>
// @license magnet:?xt=urn:btih:1f739d935676111cfff4b4693e3816e664797050&amp;dn=gpl-3.0.txt GPL-v3-or-Later
%MANAGER_OPTIONS
org_html_manager.setup();  // activate after the parameters are set
// @license-end
</script>"
  "The template for the export style additions when org-info.js is used.
Option settings will replace the %MANAGER-OPTIONS cookie."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.4")
  :type 'string)

(defun t-infojs-install-script (exp-plist _backend)
  "Install script in export options when appropriate.
EXP-PLIST is a plist containing export options.  BACKEND is the
export back-end currently used."
  (unless (or (memq 'body-only (plist-get exp-plist :export-options))
	      (not (plist-get exp-plist :html-use-infojs))
	      (and (eq (plist-get exp-plist :html-use-infojs) 'when-configured)
		   (let ((opt (plist-get exp-plist :infojs-opt)))
		     (or (not opt)
			 (string= "" opt)
			 (string-match "\\<view:nil\\>" opt)))))
    (let* ((template (plist-get exp-plist :html-infojs-template))
	   (ptoc (plist-get exp-plist :with-toc))
	   (hlevels (plist-get exp-plist :headline-levels))
	   (sdepth hlevels)
	   (tdepth (if (integerp ptoc) (min ptoc hlevels) hlevels))
	   (options (plist-get exp-plist :infojs-opt))
	   (infojs-opt (plist-get exp-plist :html-infojs-options))
	   (table t-infojs-opts-table)
	   style)
      (dolist (entry table)
	(let* ((opt (car entry))
	       (var (nth 1 entry))
	       ;; Compute default values for script option OPT from
	       ;; `t-infojs-options' variable.
	       (default
		 (let ((default (cdr (assq opt infojs-opt))))
		   (if (and (symbolp default) (not (memq default '(t nil))))
		       (plist-get exp-plist default)
		     default)))
	       ;; Value set through INFOJS_OPT keyword has precedence
	       ;; over the default one.
	       (val (if (and options
			     (string-match (format "\\<%s:\\(\\S-+\\)" opt)
					   options))
			(match-string 1 options)
		      default)))
	  (pcase opt
	    (`path (setq template
			 (replace-regexp-in-string
			  "%SCRIPT_PATH" val template t t)))
	    (`sdepth (when (integerp (read val))
		       (setq sdepth (min (read val) sdepth))))
	    (`tdepth (when (integerp (read val))
		       (setq tdepth (min (read val) tdepth))))
	    (_ (setq val
		     (cond
		      ((or (eq val t) (equal val "t")) "1")
		      ((or (eq val nil) (equal val "nil")) "0")
		      ((stringp val) val)
		      (t (format "%s" val))))
	       (push (cons var val) style)))))
      ;; Now we set the depth of the *generated* TOC to SDEPTH,
      ;; because the toc will actually determine the splitting.  How
      ;; much of the toc will actually be displayed is governed by the
      ;; TDEPTH option.
      (setq exp-plist (plist-put exp-plist :with-toc sdepth))
      ;; The table of contents should not show more sections than we
      ;; generate.
      (setq tdepth (min tdepth sdepth))
      (push (cons "TOC_DEPTH" tdepth) style)
      ;; Build style string.
      (setq style (mapconcat
		   (lambda (x)
		     (format "org_html_manager.set(\"%s\", \"%s\");"
			     (car x) (cdr x)))
		   style "\n"))
      (when (and style (> (length style) 0))
	(and (string-match "%MANAGER_OPTIONS" template)
	     (setq style (replace-match style t t template))
	     (setq exp-plist
		   (plist-put
		    exp-plist :html-head-extra
		    (concat (or (plist-get exp-plist :html-head-extra) "")
			    "\n"
			    style)))))
      ;; This script absolutely needs the table of contents, so we
      ;; change that setting.
      (unless (plist-get exp-plist :with-toc)
	(setq exp-plist (plist-put exp-plist :with-toc t)))
      ;; Return the modified property list.
      exp-plist)))

;;;; Bold, etc.

(defcustom t-text-markup-alist
  '((bold . "<b>%s</b>")
    (code . "<code>%s</code>")
    (italic . "<i>%s</i>")
    (strike-through . "<del>%s</del>")
    (underline . "<span class=\"underline\">%s</span>")
    (verbatim . "<code>%s</code>"))
  "Alist of HTML expressions to convert text markup.

The key must be a symbol among `bold', `code', `italic',
`strike-through', `underline' and `verbatim'.  The value is
a formatting string to wrap fontified text with.

If no association can be found for a given markup, text will be
returned as-is."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(alist :key-type (symbol :tag "Markup type")
		:value-type (string :tag "Format string"))
  :options '(bold code italic strike-through underline verbatim))

(defcustom t-indent nil
  "Non-nil means to indent the generated HTML.
Warning: non-nil may break indentation of source code blocks."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

;;;; Drawers

(defcustom t-format-drawer-function (lambda (_name contents) contents)
  "Function called to format a drawer in HTML code.

The function must accept two parameters:
  NAME      the drawer name, like \"LOGBOOK\"
  CONTENTS  the contents of the drawer.

The function should return the string to be exported.

The default value simply returns the value of CONTENTS."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'function)

;;;; Footnotes

(defcustom t-footnotes-section "<div id=\"footnotes\">
<h2 class=\"footnotes\">%s: </h2>
<div id=\"text-footnotes\">
%s
</div>
</div>"
  "Format for the footnotes section.
Should contain a two instances of %s.  The first will be replaced with the
language-specific word for \"Footnotes\", the second one will be replaced
by the footnotes themselves."
  :group 'org-export-yyhtml
  :type 'string)

(defcustom t-footnote-format "<sup>%s</sup>"
  "The format for the footnote reference.
%s will be replaced by the footnote reference itself."
  :group 'org-export-yyhtml
  :type 'string)

(defcustom t-footnote-separator "<sup>, </sup>"
  "Text used to separate footnotes."
  :group 'org-export-yyhtml
  :type 'string)

;;;; Headline

(defcustom t-toplevel-hlevel 2
  "The <H> level for level 1 headings in HTML export.
This is also important for the classes that will be wrapped around headlines
and outline structure.  If this variable is 1, the top-level headlines will
be <h1>, and the corresponding classes will be outline-1, section-number-1,
and outline-text-1.  If this is 2, all of these will get a 2 instead.
The default for this variable is 2, because we use <h1> for formatting the
document title."
  :group 'org-export-yyhtml
  :type 'integer)

(defcustom t-format-headline-function
  't-format-headline-default-function
  "Function to format headline text.

This function will be called with six arguments:
TODO      the todo keyword (string or nil).
TODO-TYPE the type of todo (symbol: `todo', `done', nil)
PRIORITY  the priority of the headline (integer or nil)
TEXT      the main headline text (string).
TAGS      the tags (string or nil).
INFO      the export options (plist).

The function result will be used in the section format string."
  :group 'org-export-yyhtml
  :version "26.1"
  :package-version '(Org . "8.3")
  :type 'function)

;;;; HTML-specific

(defcustom t-allow-name-attribute-in-anchors nil
  "When nil, do not set \"name\" attribute in anchors.
By default, when appropriate, anchors are formatted with \"id\"
but without \"name\" attribute."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

(defcustom t-self-link-headlines nil
  "When non-nil, the headlines contain a hyperlink to themselves."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.3")
  :type 'boolean
  :safe #'booleanp)

(defcustom t-prefer-user-labels t ; <yynt> 使用用户标记
  "When non-nil use user-defined names and ID over internal ones.

By default, Org generates its own internal ID values during HTML
export.  This process ensures that these values are unique and
valid, but the keys are not available in advance of the export
process, and not so readable.

When this variable is non-nil, Org will use NAME keyword, or the
real name of the target to create the ID attribute.

Independently of this variable, however, CUSTOM_ID are always
used as a reference."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.4")
  :type 'boolean
  :safe #'booleanp)

;;;; Inlinetasks

(defcustom t-format-inlinetask-function
  't-format-inlinetask-default-function
  "Function called to format an inlinetask in HTML code.

The function must accept seven parameters:
  TODO      the todo keyword, as a string
  TODO-TYPE the todo type, a symbol among `todo', `done' and nil.
  PRIORITY  the inlinetask priority, as a string
  NAME      the inlinetask name, as a string.
  TAGS      the inlinetask tags, as a list of strings.
  CONTENTS  the contents of the inlinetask, as a string.
  INFO      the export options, as a plist

The function should return the string to be exported."
  :group 'org-export-yyhtml
  :version "26.1"
  :package-version '(Org . "8.3")
  :type 'function)

;;;; LaTeX

(defcustom t-equation-reference-format "\\eqref{%s}"
  "The MathJax command to use when referencing equations.

This is a format control string that expects a single string argument
specifying the label that is being referenced.  The argument is
generated automatically on export.

The default is to wrap equations in parentheses (using \"\\eqref{%s}\)\".

Most common values are:

  \\eqref{%s}    Wrap the equation in parentheses
  \\ref{%s}      Do not wrap the equation in parentheses"
  :group 'org-export-yyhtml
  :package-version '(Org . "9.4")
  :type 'string
  :safe #'stringp)

(defcustom t-with-latex org-export-with-latex
  "Non-nil means process LaTeX math snippets.

When set, the exporter will process LaTeX environments and
fragments.

This option can also be set with the +OPTIONS line,
e.g. \"tex:mathjax\".  Allowed values are:

  nil           Ignore math snippets.
  `verbatim'    Keep everything in verbatim
  `mathjax', t  Do MathJax preprocessing and arrange for MathJax.js to
                be loaded.
  `html'        Use `org-latex-to-html-convert-command' to convert
                LaTeX fragments to HTML.
  SYMBOL        Any symbol defined in `org-preview-latex-process-alist',
                e.g., `dvipng'."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(choice
	  (const :tag "Do not process math in any way" nil)
	  (const :tag "Leave math verbatim" verbatim)
	  (const :tag "Use MathJax to display math" mathjax)
	  (symbol :tag "Convert to image to display math" :value dvipng)))

;;;; Links :: Generic

(defcustom t-link-org-files-as-html t
  "Non-nil means make file links to \"file.org\" point to \"file.html\".

When Org mode is exporting an Org file to HTML, links to non-HTML files
are directly put into a \"href\" tag in HTML.  However, links to other Org files
(recognized by the extension \".org\") should become links to the corresponding
HTML file, assuming that the linked Org file will also be converted to HTML.

When nil, the links still point to the plain \".org\" file."
  :group 'org-export-yyhtml
  :type 'boolean)

;;;; Links :: Inline images

(defcustom t-inline-images t
  "Non-nil means inline images into exported HTML pages.
This is done using an <img> tag.  When nil, an anchor with href is used to
link to the image."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.1")
  :type 'boolean)

(defcustom t-inline-image-rules
  `(("file" . ,(regexp-opt '(".jpeg" ".jpg" ".png" ".gif" ".svg" ".webp")))
    ("http" . ,(regexp-opt '(".jpeg" ".jpg" ".png" ".gif" ".svg" ".webp")))
    ("https" . ,(regexp-opt '(".jpeg" ".jpg" ".png" ".gif" ".svg" ".webp"))))
  "Rules characterizing image files that can be inlined into HTML.
A rule consists in an association whose key is the type of link
to consider, and value is a regexp that will be matched against
link's path."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.5")
  :type '(alist :key-type (string :tag "Type")
		:value-type (regexp :tag "Path")))

;;;; Plain Text

(defvar t-protect-char-alist
  '(("&" . "&amp;")
    ("<" . "&lt;")
    (">" . "&gt;"))
  "Alist of characters to be converted by `t-encode-plain-text'.")

;;;; Src Block

(defcustom t-htmlize-output-type 'inline-css
  "Output type to be used by htmlize when formatting code snippets.
Choices are `css' to export the CSS selectors only,`inline-css'
to export the CSS attribute values inline in the HTML or nil to
export plain text.  We use as default `inline-css', in order to
make the resulting HTML self-containing.

However, this will fail when using Emacs in batch mode for export, because
then no rich font definitions are in place.  It will also not be good if
people with different Emacs setup contribute HTML files to a website,
because the fonts will represent the individual setups.  In these cases,
it is much better to let Org/Htmlize assign classes only, and to use
a style file to define the look of these classes.
To get a start for your css file, start Emacs session and make sure that
all the faces you are interested in are defined, for example by loading files
in all modes you want.  Then, use the command
`\\[t-htmlize-generate-css]' to extract class definitions."
  :group 'org-export-yyhtml
  :type '(choice (const css) (const inline-css) (const nil)))

(defcustom t-htmlize-font-prefix "org-"
  "The prefix for CSS class names for htmlize font specifications."
  :group 'org-export-yyhtml
  :type 'string)

(defcustom t-wrap-src-lines nil
  "If non-nil, wrap individual lines of source blocks in \"code\" elements.
In this case, add line number in attribute \"data-ox-html-linenr\" when line
numbers are enabled."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.3")
  :type 'boolean
  :safe #'booleanp)

;;;; Table

(defcustom t-table-default-attributes
  '(:border "2" :cellspacing "0" :cellpadding "6" :rules "groups" :frame "hsides")
  "Default attributes and values which will be used in table tags.
This is a plist where attributes are symbols, starting with
colons, and values are strings.

When exporting to HTML5, these values will be disregarded."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(plist :key-type (symbol :tag "Property")
		:value-type (string :tag "Value")))

(defcustom t-table-header-tags '("<th scope=\"%s\"%s>" . "</th>")
  "The opening and ending tags for table header fields.
This is customizable so that alignment options can be specified.
The first %s will be filled with the scope of the field, either row or col.
The second %s will be replaced by a style entry to align the field.
See also the variable `t-table-use-header-tags-for-first-column'.
See also the variable `t-table-align-individual-fields'."
  :group 'org-export-yyhtml
  :type '(cons (string :tag "Opening tag") (string :tag "Closing tag")))

(defcustom t-table-data-tags '("<td%s>" . "</td>")
  "The opening and ending tags for table data fields.
This is customizable so that alignment options can be specified.
The first %s will be filled with the scope of the field, either row or col.
The second %s will be replaced by a style entry to align the field.
See also the variable `t-table-align-individual-fields'."
  :group 'org-export-yyhtml
  :type '(cons (string :tag "Opening tag") (string :tag "Closing tag")))

(defcustom t-table-row-open-tag "<tr>"
  "The opening tag for table rows.
This is customizable so that alignment options can be specified.
Instead of strings, these can be a Lisp function that will be
evaluated for each row in order to construct the table row tags.

The function will be called with these arguments:

         `number': row number (0 is the first row)
   `group-number': group number of current row
   `start-group?': non-nil means the row starts a group
     `end-group?': non-nil means the row ends a group
           `top?': non-nil means this is the top row
        `bottom?': non-nil means this is the bottom row

For example:

  (setq t-table-row-open-tag
        (lambda (number group-number start-group? end-group-p top? bottom?)
           (cond (top? \"<tr class=\\\"tr-top\\\">\")
                 (bottom? \"<tr class=\\\"tr-bottom\\\">\")
                 (t (if (= (mod number 2) 1)
                        \"<tr class=\\\"tr-odd\\\">\"
                      \"<tr class=\\\"tr-even\\\">\")))))

will use the \"tr-top\" and \"tr-bottom\" classes for the top row
and the bottom row, and otherwise alternate between \"tr-odd\" and
\"tr-even\" for odd and even rows."
  :group 'org-export-yyhtml
  :type '(choice :tag "Opening tag"
		 (string :tag "Specify")
		 (function)))

(defcustom t-table-row-close-tag "</tr>"
  "The closing tag for table rows.
This is customizable so that alignment options can be specified.
Instead of strings, this can be a Lisp function that will be
evaluated for each row in order to construct the table row tags.

See documentation of `t-table-row-open-tag'."
  :group 'org-export-yyhtml
  :type '(choice :tag "Closing tag"
		 (string :tag "Specify")
		 (function)))

(defcustom t-table-align-individual-fields t
  "Non-nil means attach style attributes for alignment to each table field.
When nil, alignment will only be specified in the column tags, but this
is ignored by some browsers (like Firefox, Safari).  Opera does it right
though."
  :group 'org-export-yyhtml
  :type 'boolean)

(defcustom t-table-use-header-tags-for-first-column nil
  "Non-nil means format column one in tables with header tags.
When nil, also column one will use data tags."
  :group 'org-export-yyhtml
  :type 'boolean)

(defcustom t-table-caption-above t
  "When non-nil, place caption string at the beginning of the table.
Otherwise, place it near the end."
  :group 'org-export-yyhtml
  :type 'boolean)

;;;; Tags

(defcustom t-tag-class-prefix ""
  "Prefix to class names for TODO keywords.
Each tag gets a class given by the tag itself, with this prefix.
The default prefix is empty because it is nice to just use the keyword
as a class name.  But if you get into conflicts with other, existing
CSS classes, then this prefix can be very useful."
  :group 'org-export-yyhtml
  :type 'string)

;;;; Template :: Generic

(defcustom t-extension "html"
  "The extension for exported HTML files."
  :group 'org-export-yyhtml
  :type 'string)

(defcustom t-xml-declaration
  '(("html" . "<?xml version=\"1.0\" encoding=\"%s\"?>")
    ("php" . "<?php echo \"<?xml version=\\\"1.0\\\" encoding=\\\"%s\\\" ?>\"; ?>"))
  "The extension for exported HTML files.
%s will be replaced with the charset of the exported file.
This may be a string, or an alist with export extensions
and corresponding declarations.

This declaration only applies when exporting to XHTML."
  :group 'org-export-yyhtml
  :type '(choice
	  (string :tag "Single declaration")
	  (repeat :tag "Dependent on extension"
		  (cons (string :tag "Extension")
			(string :tag "Declaration")))))

(defcustom t-coding-system 'utf-8
  "Coding system for HTML export.
Use utf-8 as the default value."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'coding-system)

(defcustom t-doctype "html5" ; <yynt> 默认 html5
  "Document type definition to use for exported HTML files.
Can be set with the in-buffer HTML_DOCTYPE property or for
publishing, with :html-doctype."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type (append
	 '(choice)
	 (mapcar (lambda (x) `(const ,(car x))) t-doctype-alist)
	 '((string :tag "Custom doctype" ))))

(defcustom t-html5-fancy t ; <yynt> 默认使用 html5 标签
  "Non-nil means using new HTML5 elements.
This variable is ignored for anything other than HTML5 export."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

(defcustom t-container-element "section" ; <yynt> 默认使用 <section>
  "HTML element to use for wrapping top level sections.
Can be set with the in-buffer HTML_CONTAINER property or for
publishing, with :html-container.

Note that changing the default will prevent you from using
org-info.js for your website."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)

(defcustom t-content-class "content"
  "CSS class name to use for the top level content wrapper.
Can be set with the in-buffer HTML_CONTENT_CLASS property or for
publishing, with :html-content-class."
  :group 'org-export-yyhtml
  :version "27.2"
  :package-version '(Org . "9.5")
  :type 'string)

(defcustom t-divs ;<yynt> content 使用 main, postamble 使用 footer
  '((preamble  "div" "preamble")
    (content   "main" "content")
    (postamble "footer" "postamble"))
  "Alist of the three section elements for HTML export.
The car of each entry is one of `preamble', `content' or `postamble'.
The cdrs of each entry are the ELEMENT_TYPE and ID for each
section of the exported document.

Note that changing the default will prevent you from using
org-info.js for your website."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(list :greedy t
	       (list :tag "Preamble"
		     (const :format "" preamble)
		     (string :tag "element") (string :tag "     id"))
	       (list :tag "Content"
		     (const :format "" content)
		     (string :tag "element") (string :tag "     id"))
	       (list :tag "Postamble" (const :format "" postamble)
		     (string :tag "     id") (string :tag "element"))))

(defconst t-checkbox-types
  '((unicode .
             ((on . "&#x2611;") (off . "&#x2610;") (trans . "&#x2610;")))
    (ascii .
           ((on . "<code>[X]</code>")
            (off . "<code>[&#xa0;]</code>")
            (trans . "<code>[-]</code>")))
    (html .
	  ((on . "<input type='checkbox' checked='checked' />")
	   (off . "<input type='checkbox' />")
	   (trans . "<input type='checkbox' />"))))
  "Alist of checkbox types.
The cdr of each entry is an alist list three checkbox types for
HTML export: `on', `off' and `trans'.

The choices are:
  `unicode' Unicode characters (HTML entities)
  `ascii'   ASCII characters
  `html'    HTML checkboxes

Note that only the ascii characters implement tri-state
checkboxes.  The other two use the `off' checkbox for `trans'.")

(defcustom t-checkbox-type 'ascii
  "The type of checkboxes to use for HTML export.
See `t-checkbox-types' for the values used for each
option."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(choice
	  (const :tag "ASCII characters" ascii)
	  (const :tag "Unicode characters" unicode)
	  (const :tag "HTML checkboxes" html)))

(defcustom t-metadata-timestamp-format "%Y-%m-%d %a %H:%M"
  "Format used for timestamps in preamble, postamble and metadata.
See `format-time-string' for more information on its components."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)

;;;; Template :: Mathjax

(defcustom t-mathjax-options
  '((path "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_HTML" )
    (scale "100")
    (align "center")
    (font "TeX")
    (linebreaks "false")
    (autonumber "AMS")
    (indent "0em")
    (multlinewidth "85%")
    (tagindent ".8em")
    (tagside "right"))
  "Options for MathJax setup.

Alist of the following elements.  All values are strings.

path          The path to MathJax.
scale         Scaling with HTML-CSS, MathML and SVG output engines.
align         How to align display math: left, center, or right.
font          The font to use with HTML-CSS and SVG output.  As of MathJax 2.5
              the following values are understood: \"TeX\", \"STIX-Web\",
              \"Asana-Math\", \"Neo-Euler\", \"Gyre-Pagella\",
              \"Gyre-Termes\", and \"Latin-Modern\".
linebreaks    Let MathJax perform automatic linebreaks.  Valid values
              are \"true\" and \"false\".
indent        If align is not center, how far from the left/right side?
              Valid values are \"left\" and \"right\"
multlinewidth The width of the multline environment.
autonumber    How to number equations.  Valid values are \"None\",
              \"all\" and \"AMS Math\".
tagindent     The amount tags are indented.
tagside       Which side to show tags/labels on.  Valid values are
              \"left\" and \"right\"

You can also customize this for each buffer, using something like

#+HTML_MATHJAX: align: left indent: 5em tagside: left font: Neo-Euler

For further information about MathJax options, see the MathJax documentation:

  https://docs.mathjax.org/"
  :group 'org-export-yyhtml
  :package-version '(Org . "8.3")
  :type '(list :greedy t
	       (list :tag "path   (the path from where to load MathJax.js)"
		     (const :format "       " path) (string))
	       (list :tag "scale  (scaling for the displayed math)"
		     (const :format "       " scale) (string))
	       (list :tag "align  (alignment of displayed equations)"
		     (const :format "       " align) (string))
	       (list :tag "font (used to display math)"
		     (const :format "            " font)
		     (choice (const "TeX")
			     (const "STIX-Web")
			     (const "Asana-Math")
			     (const "Neo-Euler")
			     (const "Gyre-Pagella")
			     (const "Gyre-Termes")
			     (const "Latin-Modern")))
	       (list :tag "linebreaks (automatic line-breaking)"
		     (const :format "      " linebreaks)
		     (choice (const "true")
			     (const "false")))
	       (list :tag "autonumber (when should equations be numbered)"
		     (const :format "      " autonumber)
		     (choice (const "AMS")
			     (const "None")
			     (const "All")))
	       (list :tag "indent (indentation with left or right alignment)"
		     (const :format "       " indent) (string))
	       (list :tag "multlinewidth (width to use for the multline environment)"
		     (const :format "       " multlinewidth) (string))
	       (list :tag "tagindent (the indentation of tags from left or right)"
		     (const :format "     " tagindent) (string))
	       (list :tag "tagside (location of tags)"
		     (const :format "      " tagside)
		     (choice (const "left")
			     (const "right")))))

(defcustom t-mathjax-template
  "<script type=\"text/x-mathjax-config\">
    MathJax.Hub.Config({
        displayAlign: \"%ALIGN\",
        displayIndent: \"%INDENT\",

        \"HTML-CSS\": { scale: %SCALE,
                        linebreaks: { automatic: \"%LINEBREAKS\" },
                        webFont: \"%FONT\"
                       },
        SVG: {scale: %SCALE,
              linebreaks: { automatic: \"%LINEBREAKS\" },
              font: \"%FONT\"},
        NativeMML: {scale: %SCALE},
        TeX: { equationNumbers: {autoNumber: \"%AUTONUMBER\"},
               MultLineWidth: \"%MULTLINEWIDTH\",
               TagSide: \"%TAGSIDE\",
               TagIndent: \"%TAGINDENT\"
             }
});
</script>
<script src=\"%PATH\"></script>"
  "The MathJax template.  See also `t-mathjax-options'."
  :group 'org-export-yyhtml
  :type 'string)

;;;; Template :: Postamble

(defcustom t-postamble t ; <yynt> 默认开启 postamble
  "Non-nil means insert a postamble in HTML export.

When set to `auto', check against the
`org-export-with-author/email/creator/date' variables to set the
content of the postamble.  When set to a string, use this string
as the postamble.  When t, insert a string as defined by the
formatting string in `t-postamble-format'.

When set to a function, apply this function and insert the
returned string.  The function takes the property list of export
options as its only argument.

Setting :html-postamble in publishing projects will take
precedence over this variable."
  :group 'org-export-yyhtml
  :type '(choice (const :tag "No postamble" nil)
		 (const :tag "Auto postamble" auto)
		 (const :tag "Default formatting string" t)
		 (string :tag "Custom formatting string")
		 (function :tag "Function (must return a string)")))

(defcustom t-postamble-format
  '(("en" "<p class=\"author\">Author: %a (%e)</p>
<p class=\"date\">Date: %d</p>
<p class=\"creator\">%c</p>
<p class=\"validation\">%v</p>"))
  "Alist of languages and format strings for the HTML postamble.

The first element of each list is the language code, as used for
the LANGUAGE keyword.  See `org-export-default-language'.

The second element of each list is a format string to format the
postamble itself.  This format string can contain these elements:

  %t stands for the title.
  %s stands for the subtitle.
  %a stands for the author's name.
  %e stands for the author's email.
  %d stands for the date.
  %c will be replaced by `t-creator-string'.
  %v will be replaced by `t-validation-link'.
  %T will be replaced by the export time.
  %C will be replaced by the last modification time.

If you need to use a \"%\" character, you need to escape it
like that: \"%%\"."
  :group 'org-export-yyhtml
  :type '(repeat
	  (list (string :tag "Language")
		(string :tag "Format string"))))

(defcustom t-validation-link
  "<a href=\"https://validator.w3.org/check?uri=referer\">Validate</a>"
  "Link to HTML validation service."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.4")
  :type 'string)

(defcustom t-creator-string
  (format "<a href=\"https://www.gnu.org/software/emacs/\">Emacs</a> %s (<a href=\"https://orgmode.org\">Org</a> mode %s)"
	  emacs-version
	  (if (fboundp 'org-version) (org-version) "unknown version"))
  "Information about the creator of the HTML document.
This option can also be set on with the CREATOR keyword."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type '(string :tag "Creator string"))

;;;; Template :: Preamble

(defcustom t-preamble t
  "Non-nil means insert a preamble in HTML export.

When t, insert a string as defined by the formatting string in
`t-preamble-format'.  When set to a string, use this
formatting string instead (see `t-postamble-format' for an
example of such a formatting string).

When set to a function, apply this function and insert the
returned string.  The function takes the property list of export
options as its only argument.

Setting :html-preamble in publishing projects will take
precedence over this variable."
  :group 'org-export-yyhtml
  :type '(choice (const :tag "No preamble" nil)
		 (const :tag "Default preamble" t)
		 (string :tag "Custom formatting string")
		 (function :tag "Function (must return a string)")))

(defcustom t-preamble-format '(("en" ""))
  "Alist of languages and format strings for the HTML preamble.

The first element of each list is the language code, as used for
the LANGUAGE keyword.  See `org-export-default-language'.

The second element of each list is a format string to format the
preamble itself.  This format string can contain these elements:

  %t stands for the title.
  %s stands for the subtitle.
  %a stands for the author's name.
  %e stands for the author's email.
  %d stands for the date.
  %c will be replaced by `t-creator-string'.
  %v will be replaced by `t-validation-link'.
  %T will be replaced by the export time.
  %C will be replaced by the last modification time.

If you need to use a \"%\" character, you need to escape it
like that: \"%%\".

See the default value of `t-postamble-format' for an
example."
  :group 'org-export-yyhtml
  :type '(repeat
	  (list (string :tag "Language")
		(string :tag "Format string"))))

(defcustom t-link-up ""
  "Where should the \"UP\" link of exported HTML pages lead?"
  :group 'org-export-yyhtml
  :type '(string :tag "File or URL"))

(defcustom t-link-home ""
  "Where should the \"HOME\" link of exported HTML pages lead?"
  :group 'org-export-yyhtml
  :type '(string :tag "File or URL"))

(defcustom t-link-use-abs-url nil
  "Should we prepend relative links with HTML_LINK_HOME?"
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.1")
  :type 'boolean)

;; <yynt> 修改了默认的格式化字符串，可以添加自定义名字
(defcustom t-home/up-format
  "<div id=\"org-div-home-and-up\">
<a href=\"%s\"> %s </a>
<a href=\"%s\"> %s </a>
</div>\n"
  "Snippet used to insert the HOME and UP links.
This is a format string, the first %s will receive the UP link,
the second the HOME link.  If both `t-link-up' and
`t-link-home' are empty, the entire snippet will be
ignored."
  :group 'org-export-yyhtml
  :type 'string)

;;;; Template :: Scripts

(defcustom t-head-include-scripts nil
  "Non-nil means include the JavaScript snippets in exported HTML files.
The actual script is defined in `t-scripts'."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

;;;; Template :: Styles

(defcustom t-meta-tags #'t-meta-tags-default
  "Form that is used to produce meta tags in the HTML head.

Can be a list where each item is a list of arguments to be passed
to `t--build-meta-entry'.  Any nil items are ignored.

Also accept a function which gives such a list when called with a
single argument (INFO, a communication plist)."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.5")
  :type '(choice
	  (repeat
	   (list (string :tag "Meta label")
		 (string :tag "label value")
		 (string :tag "Content value")))
	  function))

(defcustom t-head-include-default-style nil ; <yynt> 不使用默认 CSS
  "Non-nil means include the default style in exported HTML files.
The actual style is defined in `t-style-default' and
should not be modified.  Use `t-head' to use your own
style information."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)
;;;###autoload
(put 't-head-include-default-style 'safe-local-variable 'booleanp)

(defcustom t-head ""
  "Org-wide head definitions for exported HTML files.

This variable can contain the full HTML structure to provide a
style, including the surrounding HTML tags.  You can consider
including definitions for the following classes: title, todo,
done, timestamp, timestamp-kwd, tag, target.

For example, a valid value would be:

   <style>
      p { font-weight: normal; color: gray; }
      h1 { color: black; }
      .title { text-align: center; }
      .todo, .timestamp-kwd { color: red; }
      .done { color: green; }
   </style>

If you want to refer to an external style, use something like

   <link rel=\"stylesheet\" type=\"text/css\" href=\"mystyles.css\" />

As the value of this option simply gets inserted into the HTML
<head> header, you can use it to add any arbitrary text to the
header.

You can set this on a per-file basis using #+HTML_HEAD:,
or for publication projects using the :html-head property."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)
;;;###autoload
(put 't-head 'safe-local-variable 'stringp)

(defcustom t-head-extra ""
  "More head information to add in the HTML output.

You can set this on a per-file basis using #+HTML_HEAD_EXTRA:,
or for publication projects using the :html-head-extra property."
  :group 'org-export-yyhtml
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'string)
;;;###autoload
(put 't-head-extra 'safe-local-variable 'stringp)

;;;; Template :: Viewport

(defcustom t-viewport '((width "device-width")
			       (initial-scale "1")
			       (minimum-scale "")
			       (maximum-scale "")
			       (user-scalable ""))
  "Viewport options for mobile-optimized sites.

The following values are recognized

width          Size of the viewport.
initial-scale  Zoom level when the page is first loaded.
minimum-scale  Minimum allowed zoom level.
maximum-scale  Maximum allowed zoom level.
user-scalable  Whether zoom can be changed.

The viewport meta tag is inserted if this variable is non-nil.

See the following site for a reference:
https://developer.mozilla.org/en-US/docs/Mozilla/Mobile/Viewport_meta_tag"
  :group 'org-export-yyhtml
  :version "26.1"
  :package-version '(Org . "8.3")
  :type '(choice (const :tag "Disable" nil)
		 (list :tag "Enable"
		       (list :tag "Width of viewport"
			     (const :format "             " width)
			     (choice (const :tag "unset" "")
				     (string)))
		       (list :tag "Initial scale"
			     (const :format "             " initial-scale)
			     (choice (const :tag "unset" "")
				     (string)))
		       (list :tag "Minimum scale/zoom"
			     (const :format "             " minimum-scale)
			     (choice (const :tag "unset" "")
				     (string)))
		       (list :tag "Maximum scale/zoom"
			     (const :format "             " maximum-scale)
			     (choice (const :tag "unset" "")
				     (string)))
		       (list :tag "User scalable/zoomable"
			     (const :format "             " user-scalable)
			     (choice (const :tag "unset" "")
				     (const "true")
				     (const "false"))))))

;; Handle source code blocks with Klipse

(defcustom t-klipsify-src nil
  "When non-nil, source code blocks are editable in exported presentation."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.1")
  :type 'boolean)

(defcustom t-klipse-css
  "https://storage.googleapis.com/app.klipse.tech/css/codemirror.css"
  "Location of the codemirror CSS file for use with klipse."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.1")
  :type 'string)

(defcustom t-klipse-js
  "https://storage.googleapis.com/app.klipse.tech/plugin_prod/js/klipse_plugin.min.js"
  "Location of the klipse javascript file."
  :group 'org-export-yyhtml
  :type 'string)

(defcustom t-klipse-selection-script
  "window.klipse_settings = {selector_eval_html: '.src-html',
                             selector_eval_js: '.src-js',
                             selector_eval_python_client: '.src-python',
                             selector_eval_scheme: '.src-scheme',
                             selector: '.src-clojure',
                             selector_eval_ruby: '.src-ruby'};"
  "Javascript snippet to activate klipse."
  :group 'org-export-yyhtml
  :package-version '(Org . "9.1")
  :type 'string)


;;;; Todos

(defcustom t-todo-kwd-class-prefix ""
  "Prefix to class names for TODO keywords.
Each TODO keyword gets a class given by the keyword itself, with this prefix.
The default prefix is empty because it is nice to just use the keyword
as a class name.  But if you get into conflicts with other, existing
CSS classes, then this prefix can be very useful."
  :group 'org-export-yyhtml
  :type 'string)


;;; Internal Functions

(defun t-xhtml-p (info)
  (let ((dt (downcase (plist-get info :html-doctype))))
    (string-match-p "xhtml" dt)))

(defun t-html5-p (info)
  (let ((dt (downcase (plist-get info :html-doctype))))
    (member dt '("html5" "xhtml5" "<!doctype html>"))))

(defun t--html5-fancy-p (info)
  "Non-nil when exporting to HTML5 with fancy elements.
INFO is the current state of the export process, as a plist."
  (and (plist-get info :html-html5-fancy)
       (t-html5-p info)))

(defun t-close-tag (tag attr info)
  "Return close-tag for string TAG.
ATTR specifies additional attributes.  INFO is a property list
containing current export state."
  (concat "<" tag
	  (org-string-nw-p (concat " " attr))
	  (if (t-xhtml-p info) " />" ">")))

(defun t-doctype (info)
  "Return correct HTML doctype tag.
INFO is a plist used as a communication channel.  Doctype tag is
extracted from `t-doctype-alist', or the literal value
of :html-doctype from INFO if :html-doctype is not found in the
alist."
  (let ((dt (plist-get info :html-doctype)))
    (or (cdr (assoc dt t-doctype-alist)) dt)))

(defun t--make-attribute-string (attributes)
  "Return a list of attributes, as a string.
ATTRIBUTES is a plist where values are either strings or nil.  An
attribute with a nil value will be omitted from the result."
  (let (output)
    (dolist (item attributes (mapconcat 'identity (nreverse output) " "))
      (cond ((null item) (pop output))
            ((symbolp item) (push (substring (symbol-name item) 1) output))
            (t (let ((key (car output))
                     (value (replace-regexp-in-string
                             "\"" "&quot;" (t-encode-plain-text item))))
                 (setcar output (format "%s=\"%s\"" key value))))))))

(defun t--reference (datum info &optional named-only)
  "Return an appropriate reference for DATUM.

DATUM is an element or a `target' type object.  INFO is the
current export state, as a plist.

When NAMED-ONLY is non-nil and DATUM has no NAME keyword, return
nil.  This doesn't apply to headlines, inline tasks, radio
targets and targets."
  (let* ((type (org-element-type datum))
	 (user-label
	  (org-element-property
	   (pcase type
	     ((or `headline `inlinetask) :CUSTOM_ID)
	     ((or `radio-target `target) :value)
	     (_ :name))
	   datum)))
    (cond
     ((and user-label
	   (or (plist-get info :html-prefer-user-labels)
	       ;; Used CUSTOM_ID property unconditionally.
	       (memq type '(headline inlinetask))))
      user-label)
     ((and named-only
	   (not (memq type '(headline inlinetask radio-target target)))
	   (not user-label))
      nil)
     (t
      (t-get-reference datum info))))) ; <yynt> 架空 org-export-get-reference

;; <yynt> 魔改的 org-export-get-reference，处理标题 id
(defun t-get-reference (datum info)
  (let ((cache (plist-get info :internal-references)))
    (or (car (rassq datum cache))
	(let* ((crossrefs (plist-get info :crossrefs))
	       (cells (org-export-search-cells datum))
	       (new (or (cl-some
			 (lambda (cell)
			   (let ((stored (cdr (assoc cell crossrefs))))
			     (when stored
			       (let ((old (t-format-reference stored)))
				 (and (not (assoc old cache)) stored)))))
			 cells)
			(when (eq 'headline (org-element-type datum))
			  (if-let ((numbers (org-export-get-headline-number datum info)))
			      (concat "-H-" (mapconcat #'number-to-string numbers "➈"))
			    (concat "-NH-" (number-to-string
					   (cl-incf (plist-get info :html-headline-cnt))))))
			(org-export-new-reference cache)))
	       (reference-string (t-format-reference new)))
	  (dolist (cell cells) (push (cons cell new) cache))
	  (push (cons reference-string datum) cache)
	  (plist-put info :internal-references cache)
	  reference-string))))
(defun t-format-reference (new)
  (format "org%s" new))

(defun t--wrap-image (contents info &optional caption label)
  "Wrap CONTENTS string within an appropriate environment for images.
INFO is a plist used as a communication channel.  When optional
arguments CAPTION and LABEL are given, use them for caption and
\"id\" attribute."
  (let ((html5-fancy (t--html5-fancy-p info)))
    (format (if html5-fancy "\n<figure%s>\n%s%s</figure>" ; <yynt> 去掉末尾的 \n，且去掉 figure 的 id
	      "\n<div class=\"figure\">\n%s%s\n</div>")
	    ;; ID. <yynt> 不使用 id
	    (if (org-string-nw-p label) (format " id=\"%s\"" label) "")
	    ;; Contents.
	    (if html5-fancy contents (format "<p>%s</p>" contents))
	    ;; Caption.
	    (if (not (org-string-nw-p caption)) ""
	      (format (if html5-fancy "<figcaption>%s</figcaption>\n" ; <yynt> 将开头 \n 去掉加到末尾
			"\n<p>%s</p>")
		      caption)))))

(defun t--format-image (source attributes info)
  "Return \"img\" tag with given SOURCE and ATTRIBUTES.
SOURCE is a string specifying the location of the image.
ATTRIBUTES is a plist, as returned by
`org-export-read-attribute'.  INFO is a plist used as
a communication channel."
  (t-close-tag
   "img"
   (t--make-attribute-string
    (org-combine-plists
     (list :src source
           :alt (if (string-match-p
                     (concat "^" org-preview-latex-image-directory) source)
                    (t-encode-plain-text
                     (org-find-text-property-in-string 'org-latex-src source))
                  (file-name-nondirectory source)))
     (if (string= "svg" (file-name-extension source))
         (org-combine-plists '(:class "org-svg") attributes '(:fallback nil))
       attributes)))
   info))

(defun t--textarea-block (element)
  "Transcode ELEMENT into a textarea block.
ELEMENT is either a source or an example block."
  (let* ((code (car (org-export-unravel-code element)))
	 (attr (org-export-read-attribute :attr_html element)))
    (format "<p>\n<textarea cols=\"%s\" rows=\"%s\">\n%s</textarea>\n</p>"
	    (or (plist-get attr :width) 80)
	    (or (plist-get attr :height) (org-count-lines code))
	    code)))

(defun t--has-caption-p (element &optional _info)
  "Non-nil when ELEMENT has a caption affiliated keyword.
INFO is a plist used as a communication channel.  This function
is meant to be used as a predicate for `org-export-get-ordinal' or
a value to `t-standalone-image-predicate'."
  (org-element-property :caption element))

;;;; Table

(defun t-htmlize-region-for-paste (beg end)
  "Convert the region between BEG and END to HTML, using htmlize.el.
This is much like `htmlize-region-for-paste', only that it uses
the settings define in the org-... variables."
  (let* ((htmlize-output-type t-htmlize-output-type)
	 (htmlize-css-name-prefix t-htmlize-font-prefix)
	 (htmlbuf (htmlize-region beg end)))
    (unwind-protect
	(with-current-buffer htmlbuf
	  (buffer-substring (plist-get htmlize-buffer-places 'content-start)
			    (plist-get htmlize-buffer-places 'content-end)))
      (kill-buffer htmlbuf))))

;;;###autoload
(defun t-htmlize-generate-css ()
  "Create the CSS for all font definitions in the current Emacs session.
Use this to create face definitions in your CSS style file that can then
be used by code snippets transformed by htmlize.
This command just produces a buffer that contains class definitions for all
faces used in the current Emacs session.  You can copy and paste the ones you
need into your CSS file.

If you then set `t-htmlize-output-type' to `css', calls
to the function `t-htmlize-region-for-paste' will
produce code that uses these same face definitions."
  (interactive)
  (unless (require 'htmlize nil t)
    (error "htmlize library missing.  Aborting"))
  (and (get-buffer "*html*") (kill-buffer "*html*"))
  (with-temp-buffer
    (let ((fl (face-list))
	  (htmlize-css-name-prefix "org-")
	  (htmlize-output-type 'css)
	  f i)
      (while (setq f (pop fl)
		   i (and f (face-attribute f :inherit)))
	(when (and (symbolp f) (or (not i) (not (listp i))))
	  (insert (org-add-props (copy-sequence "1") nil 'face f))))
      (htmlize-region (point-min) (point-max))))
  (pop-to-buffer-same-window "*html*")
  (goto-char (point-min))
  (when (re-search-forward "<style" nil t)
    (delete-region (point-min) (match-beginning 0)))
  (when (re-search-forward "</style>" nil t)
    (delete-region (1+ (match-end 0)) (point-max)))
  (beginning-of-line 1)
  (when (looking-at " +") (replace-match ""))
  (goto-char (point-min)))

(defun t--make-string (n string)
  "Build a string by concatenating N times STRING."
  (let (out) (dotimes (_ n out) (setq out (concat string out)))))

(defun t-fix-class-name (kwd)	; audit callers of this function
  "Turn todo keyword KWD into a valid class name.
Replaces invalid characters with \"_\"."
  (replace-regexp-in-string "[^a-zA-Z0-9_]" "_" kwd nil t))

(defun t-footnote-section (info)
  "Format the footnote section.
INFO is a plist used as a communication channel."
  (pcase (org-export-collect-footnote-definitions info)
    (`nil nil)
    (definitions
      (format
       (plist-get info :html-footnotes-section)
       (t--translate "Footnotes" info)
       (format
	"\n%s\n"
	(mapconcat
	 (lambda (definition)
	   (pcase definition
	     (`(,n ,_ ,def)
	      ;; `org-export-collect-footnote-definitions' can return
	      ;; two kinds of footnote definitions: inline and blocks.
	      ;; Since this should not make any difference in the HTML
	      ;; output, we wrap the inline definitions within
	      ;; a "footpara" class paragraph.
	      (let ((inline? (not (org-element-map def org-element-all-elements
				    #'identity nil t)))
		    (anchor (t--anchor
			     (format "fn.%d" n)
			     n
			     (format " class=\"footnum\" href=\"#fnr.%d\" role=\"doc-backlink\"" n)
			     info))
		    (contents (org-trim (org-export-data def info))))
		(format "<div class=\"footdef\">%s %s</div>\n"
			(format (plist-get info :html-footnote-format) anchor)
			(format "<div class=\"footpara\" role=\"doc-footnote\">%s</div>"
				(if (not inline?) contents
				  (format "<p class=\"footpara\">%s</p>"
					  contents))))))))
	 definitions
	 "\n"))))))


;;; Template

(defun t-meta-tags-default (info)
  "A default value for `t-meta-tags'.

Generate a list items, each of which is a list of arguments that can
be passed to `t--build-meta-entry', to generate meta tags to be
included in the HTML head.

Use document's plist INFO to derive relevant information for the tags."
  (let ((author (and (plist-get info :with-author)
                     (let ((auth (plist-get info :author)))
                       ;; Return raw Org syntax.
                       (and auth (org-element-interpret-data auth))))))
    (list
     (when (org-string-nw-p author)
       (list "name" "author" author))
     (when (org-string-nw-p (plist-get info :description))
       (list "name" "description"
             (plist-get info :description)))
     (when (org-string-nw-p (plist-get info :keywords))
       (list "name" "keywords" (plist-get info :keywords)))
     '("name" "generator" "Org Mode"))))

(defun t--build-meta-entry
    (label identity &optional content-format &rest content-formatters)
  "Build a meta tag using the provided information.

Construct <meta> tag of form <meta LABEL=\"IDENTITY\" />, or when CONTENT-FORMAT
is present: <meta LABEL=\"IDENTITY\" content=\"{content}\" />

Here {content} is determined by applying any CONTENT-FORMATTERS to the
CONTENT-FORMAT and encoding the result as plain text."
  (concat "<meta "
	  (format "%s=\"%s" label identity)
	  (when content-format
	    (concat "\" content=\""
		    (replace-regexp-in-string
		     "\"" "&quot;"
		     (t-encode-plain-text
		      (if content-formatters
			  (apply #'format content-format content-formatters)
			content-format)))))
	  "\">\n")) ; <yynt> 移除了多余的 `/'

(defun t--build-meta-info (info)
  "Return meta tags for exported document.
INFO is a plist used as a communication channel."
  (let* ((title (t-plain-text
		 (org-element-interpret-data (plist-get info :title)) info))
	 ;; Set title to an invisible character instead of leaving it
	 ;; empty, which is invalid.
	 (title (if (org-string-nw-p title) title "&lrm;"))
	 (charset (or (and t-coding-system
			   (fboundp 'coding-system-get)
			   (symbol-name
			    (coding-system-get t-coding-system
					       'mime-charset)))
		      "iso-8859-1")))
    (concat
     (when (plist-get info :time-stamp-file)
       (format-time-string
	(concat "<!-- "
		(plist-get info :html-metadata-timestamp-format)
		" -->\n")))

     (if (t-html5-p info)
	 (t--build-meta-entry "charset" charset)
       (t--build-meta-entry "http-equiv" "Content-Type"
				   (concat "text/html;charset=" charset)))

     (let ((viewport-options
	    (cl-remove-if-not (lambda (cell) (org-string-nw-p (cadr cell)))
			      (plist-get info :html-viewport))))
       (if viewport-options
	   (t--build-meta-entry "name" "viewport"
				       (mapconcat
					(lambda (elm)
                                          (format "%s=%s" (car elm) (cadr elm)))
					viewport-options ", "))))

     (format "<title>%s</title>\n" title)

     (mapconcat
      (lambda (args) (apply #'t--build-meta-entry args))
      (delq nil (if (functionp t-meta-tags)
		    (funcall t-meta-tags info)
		  t-meta-tags))
      ""))))

(defun t--build-head (info)
  "Return information for the <head>..</head> of the HTML output.
INFO is a plist used as a communication channel."
  (org-element-normalize-string
   (concat
    (when (plist-get info :html-head-include-default-style)
      (org-element-normalize-string t-style-default))

    ;; (org-element-normalize-string (plist-get info :html-head))
    ;; (org-element-normalize-string (plist-get info :html-head-extra))
    ;; <yynt> 添加了可以添加额外内容的函数 HTML_HEAD_FUNC，它会覆盖 HTML_HEAD 和 HTML_HEAD_EXTRA
    (org-element-normalize-string
     (if-let ((fun (plist-get info :html-head-func)))
	 (funcall (intern fun) info)
       (concat (org-element-normalize-string (plist-get info :html-head))
	       (org-element-normalize-string (plist-get info :html-head-extra)))))

    (when (and (plist-get info :html-htmlized-css-url)
	       (eq t-htmlize-output-type 'css))
      (t-close-tag "link"
		   (format "rel=\"stylesheet\" href=\"%s\" type=\"text/css\""
			   (plist-get info :html-htmlized-css-url))
		   info))
    (when (plist-get info :html-head-include-scripts) t-scripts))))

(defun t--build-mathjax-config (info)
  "Insert the user setup into the mathjax template.
INFO is a plist used as a communication channel."
  (when (and (memq (plist-get info :with-latex) '(mathjax t))
	     (org-element-map (plist-get info :parse-tree)
		 '(latex-fragment latex-environment) #'identity info t nil t))
    (let ((template (plist-get info :html-mathjax-template))
	  (options (plist-get info :html-mathjax-options))
	  (in-buffer (or (plist-get info :html-mathjax) "")))
      (dolist (e options (org-element-normalize-string template))
	(let ((name (car e))
	      (val (nth 1 e)))
	  (when (string-match (concat "\\<" (symbol-name name) ":") in-buffer)
	    (setq val
		  (car (read-from-string (substring in-buffer (match-end 0))))))
	  (unless (stringp val) (setq val (format "%s" val)))
	  (while (string-match (concat "%" (upcase (symbol-name name)))
			       template)
	    (setq template (replace-match val t t template))))))))

(defun t-format-spec (info)
  "Return format specification for preamble and postamble.
INFO is a plist used as a communication channel."
  (let ((timestamp-format (plist-get info :html-metadata-timestamp-format)))
    `((?t . ,(org-export-data (plist-get info :title) info))
      (?s . ,(org-export-data (plist-get info :subtitle) info))
      (?d . ,(org-export-data (org-export-get-date info timestamp-format)
			      info))
      (?T . ,(format-time-string timestamp-format))
      (?a . ,(org-export-data (plist-get info :author) info))
      (?e . ,(mapconcat
	      (lambda (e) (format "<a href=\"mailto:%s\">%s</a>" e e))
	      (split-string (plist-get info :email)  ",+ *")
	      ", "))
      (?c . ,(plist-get info :creator))
      (?C . ,(let ((file (plist-get info :input-file)))
	       (format-time-string timestamp-format
				   (and file (file-attribute-modification-time
					      (file-attributes file))))))
      (?v . ,(or (plist-get info :html-validation-link) "")))))

(defun t--build-pre/postamble (type info)
  "Return document preamble or postamble as a string, or nil.
TYPE is either `preamble' or `postamble', INFO is a plist used as a
communication channel."
  (let ((section (plist-get info (intern (format ":html-%s" type))))
	(spec (t-format-spec info)))
    (when section
      (let ((section-contents
	     (if (functionp section) (funcall section info)
	       (cond
		((stringp section) (format-spec section spec))
		((eq section 'auto)
		 (let ((date (cdr (assq ?d spec)))
		       (author (cdr (assq ?a spec)))
		       (email (cdr (assq ?e spec)))
		       (creator (cdr (assq ?c spec)))
		       (validation-link (cdr (assq ?v spec))))
		   (concat
		    (and (plist-get info :with-date)
			 (org-string-nw-p date)
			 (format "<p class=\"date\">%s: %s</p>\n"
				 (t--translate "Date" info)
				 date))
		    (and (plist-get info :with-author)
			 (org-string-nw-p author)
			 (format "<p class=\"author\">%s: %s</p>\n"
				 (t--translate "Author" info)
				 author))
		    (and (plist-get info :with-email)
			 (org-string-nw-p email)
			 (format "<p class=\"email\">%s: %s</p>\n"
				 (t--translate "Email" info)
				 email))
		    (and (plist-get info :time-stamp-file)
			 (format
			  "<p class=\"date\">%s: %s</p>\n"
			  (t--translate "Created" info)
			  (format-time-string
			   (plist-get info :html-metadata-timestamp-format))))
		    (and (plist-get info :with-creator)
			 (org-string-nw-p creator)
			 (format "<p class=\"creator\">%s</p>\n" creator))
		    (and (org-string-nw-p validation-link)
			 (format "<p class=\"validation\">%s</p>\n"
				 validation-link)))))
		(t
		 ;; <yynt> 添加了对扩展形式 preamble 和 postamle 的处理
		 (let ((ways (if (eq type 'preamble)
				 '(:html-new-preamble-func :html-new-preamble)
			       '(:html-new-postamble-func :html-new-postamble))))
		   (if-let ((symstr (plist-get info (car ways))))
		       (format-spec (funcall (intern symstr) info) spec)
		     (if-let ((str (plist-get info (cadr ways))))
			   (format-spec str spec)
		       (let ((formats (plist-get info (if (eq type 'preamble)
							  :html-preamble-format
							:html-postamble-format)))
			     (language (plist-get info :language)))
			 (format-spec
			  (cadr (or (assoc-string language formats t)
				    (assoc-string "en" formats t)))
			  spec))))))))))
	(let ((div (assq type (plist-get info :html-divs))))
	  (when (org-string-nw-p section-contents)
	    (concat
	     (format "<%s id=\"%s\" class=\"%s\">\n"
		     (nth 1 div)
		     (nth 2 div)
		     t--pre/postamble-class)
	     (org-element-normalize-string section-contents)
	     (format "</%s>\n" (nth 1 div)))))))))

(defun t-inner-template (contents info)
  "Return body of document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   ;; Table of contents.
   (let ((depth (plist-get info :with-toc)))
     (when depth (t-toc depth info)))
   ;; Document contents.
   contents
   ;; Footnotes section.
   (t-footnote-section info)))

(defun t-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   (when (and (not (t-html5-p info)) (t-xhtml-p info))
     (let* ((xml-declaration (plist-get info :html-xml-declaration))
	    (decl (or (and (stringp xml-declaration) xml-declaration)
		      (cdr (assoc (plist-get info :html-extension)
				  xml-declaration))
		      (cdr (assoc "html" xml-declaration))
		      "")))
       (when (not (or (not decl) (string= "" decl)))
	 (format "%s\n"
		 (format decl
			 (or (and t-coding-system
				  (fboundp 'coding-system-get)
				  (coding-system-get t-coding-system 'mime-charset))
			     "iso-8859-1"))))))
   (t-doctype info)
   "\n"
   (concat "<html"
	   (cond ((t-xhtml-p info)
		  (format
		   " xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\""
		   (plist-get info :language) (plist-get info :language)))
		 ((t-html5-p info)
		  (format " lang=\"%s\"" (plist-get info :language))))
	   ">\n")
   "<head>\n"
   (t--build-meta-info info)
   (t--build-head info)
   (t--build-mathjax-config info)
   "</head>\n"
   "<body>\n"
   ;; <yynt> ，为 home/up link 添加更多选项
   ;; 格式字符串需要采取 %s(Llink) %s(Lname) %s(Rlink) %s(Rname) 的顺序
   ;; 或是直接通过 HTML_LINK_FUNC 指定返回字符串的函数
   (if-let ((funstr (plist-get info :html-link-func)))
       (org-element-normalize-string (funcall (intern funstr) info))
     (let ((link-up (org-trim (plist-get info :html-link-up)))
	   (link-home (org-trim (plist-get info :html-link-home)))
	   (link-left (org-trim (plist-get info :html-link-left)))
	   (link-right (org-trim (plist-get info :html-link-right)))
	   (link-lname (org-trim (plist-get info :html-link-lname)))
	   (link-rname (org-trim (plist-get info :html-link-rname))))
       (unless (and (string= link-up "") (string= link-home "")
		    (string= link-left "") (string= link-right ""))
	 (format (plist-get info :html-home/up-format)
		 (cl-find-if-not (lambda (x) (string= "" x))
				 (list link-left link-right link-up link-home))
		 link-lname
		 (cl-find-if-not (lambda (x) (string= "" x))
				 (list link-right link-left link-home link-up))
		 link-rname))))
   ;; Preamble.
   (t--build-pre/postamble 'preamble info)
   ;; Document contents.
   (let ((div (assq 'content (plist-get info :html-divs))))
     (format "<%s id=\"%s\" class=\"%s\">\n"
             (nth 1 div)
             (nth 2 div)
             (plist-get info :html-content-class)))
   ;; Document title.
   (when (plist-get info :with-title)
     (let ((title (and (plist-get info :with-title)
		       (plist-get info :title)))
	   (subtitle (plist-get info :subtitle))
	   (html5-fancy (t--html5-fancy-p info)))
       (when title
	 (format
	  (if html5-fancy
	      "<header>\n<h1 class=\"title\">%s</h1>\n%s</header>\n" ; <yynt> 添加标题末尾换行
	    "<h1 class=\"title\">%s%s</h1>\n")
	  (org-export-data title info)
	  (if subtitle
	      (format
	       (if html5-fancy
		   "<p class=\"subtitle\" role=\"doc-subtitle\">%s</p>\n"
		 (concat "\n" (t-close-tag "br" nil info) "\n"
			 "<span class=\"subtitle\">%s</span>\n"))
	       (org-export-data subtitle info))
	    "")))))
   contents
   (format "</%s>\n" (nth 1 (assq 'content (plist-get info :html-divs))))
   ;; Postamble.
   (t--build-pre/postamble 'postamble info)
   ;; Possibly use the Klipse library live code blocks.
   (when (plist-get info :html-klipsify-src)
     (concat "<script>" (plist-get info :html-klipse-selection-script)
	     "</script><script src=\""
	     t-klipse-js
	     "\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\""
	     t-klipse-css "\"/>"))
   ;; Closing document.
   "</body>\n</html>"))

(defun t--translate (s info)
  "Translate string S according to specified language.
INFO is a plist used as a communication channel."
  (org-export-translate s :html info))

;;;; Anchor

(defun t--anchor (id desc attributes info)
  "Format a HTML anchor."
  (let* ((name (and (plist-get info :html-allow-name-attribute-in-anchors) id))
	 (attributes (concat (and id (format " id=\"%s\"" id))
			     (and name (format " name=\"%s\"" name))
			     attributes)))
    (format "<a%s>%s</a>" attributes (or desc ""))))

;;;; Todo

(defun t--todo (todo info)
  "Format TODO keywords into HTML."
  (when todo
    (format "<span class=\"%s %s%s\">%s</span>"
	    (if (member todo org-done-keywords) "done" "todo")
	    (or (plist-get info :html-todo-kwd-class-prefix) "")
	    (t-fix-class-name todo)
	    todo)))

;;;; Priority

(defun t--priority (priority _info)
  "Format a priority into HTML.
PRIORITY is the character code of the priority or nil.  INFO is
a plist containing export options."
  (and priority (format "<span class=\"priority\">[%c]</span>" priority)))

;;;; Tags

(defun t--tags (tags info)
  "Format TAGS into HTML.
INFO is a plist containing export options."
  (when tags
    (format "<span class=\"tag\">%s</span>"
	    (mapconcat
	     (lambda (tag)
	       (format "<span class=\"%s\">%s</span>"
		       (concat (plist-get info :html-tag-class-prefix)
			       (t-fix-class-name tag))
		       tag))
	     tags "&#xa0;"))))

;;;; Src Code

(defun t-fontify-code (code lang)
  "Color CODE with htmlize library.
CODE is a string representing the source code to colorize.  LANG
is the language used for CODE, as a string, or nil."
  (when code
    (cond
     ;; No language.  Possibly an example block.
     ((not lang) (t-encode-plain-text code))
     ;; Plain text explicitly set.
     ((not t-htmlize-output-type) (t-encode-plain-text code))
     ;; No htmlize library or an inferior version of htmlize.
     ((not (progn (require 'htmlize nil t)
		  (fboundp 'htmlize-region-for-paste)))
      ;; Emit a warning.
      (message "Cannot fontify source block (htmlize.el >= 1.34 required)")
      (t-encode-plain-text code))
     (t
      ;; Map language
      (setq lang (or (assoc-default lang org-src-lang-modes) lang))
      (let* ((lang-mode (and lang (intern (format "%s-mode" lang)))))
	(cond
	 ;; Case 1: Language is not associated with any Emacs mode
	 ((not (functionp lang-mode))
	  (t-encode-plain-text code))
	 ;; Case 2: Default.  Fontify code.
	 (t
	  ;; htmlize
	  (setq code
		(let ((output-type t-htmlize-output-type)
		      (font-prefix t-htmlize-font-prefix)
		      (inhibit-read-only t))
		  (with-temp-buffer
		    ;; Switch to language-specific mode.
		    (funcall lang-mode)
		    (insert code)
		    ;; Fontify buffer.
		    (font-lock-ensure)
		    ;; Remove formatting on newline characters.
		    (save-excursion
		      (let ((beg (point-min))
			    (end (point-max)))
			(goto-char beg)
			(while (progn (end-of-line) (< (point) end))
			  (put-text-property (point) (1+ (point)) 'face nil)
			  (forward-char 1))))
		    (org-src-mode)
		    (set-buffer-modified-p nil)
		    ;; Htmlize region.
		    (let ((t-htmlize-output-type output-type)
			  (t-htmlize-font-prefix font-prefix))
		      (t-htmlize-region-for-paste
		       (point-min) (point-max))))))
	  ;; Strip any enclosing <pre></pre> tags.
	  (let* ((beg (and (string-match "\\`<pre[^>]*>\n?" code) (match-end 0)))
		 (end (and beg (string-match "</pre>\\'" code))))
	    (if (and beg end) (substring code beg end) code)))))))))

(defun t-do-format-code
    (code &optional lang refs retain-labels num-start wrap-lines)
  "Format CODE string as source code.
Optional arguments LANG, REFS, RETAIN-LABELS, NUM-START, WRAP-LINES
are, respectively, the language of the source code, as a string, an
alist between line numbers and references (as returned by
`org-export-unravel-code'), a boolean specifying if labels should
appear in the source code, the number associated to the first
line of code, and a boolean specifying if lines of code should be
wrapped in code elements."
  (let* ((code-lines (split-string code "\n"))
	 (code-length (length code-lines))
	 (num-fmt
	  (and num-start
	       (format "%%%ds: "
		       (length (number-to-string (+ code-length num-start))))))
	 (code (t-fontify-code code lang)))
    (org-export-format-code
     code
     (lambda (loc line-num ref)
       (setq loc
	     (concat
	      ;; Add line number, if needed.
	      (when num-start
		(format "<span class=\"linenr\">%s</span>"
			(format num-fmt line-num)))
	      ;; Transcoded src line.
	      (if wrap-lines
		  (format "<code%s>%s</code>"
			  (if num-start
                              (format " data-ox-html-linenr=\"%s\"" line-num)
                            "")
			  loc)
		loc)
	      ;; Add label, if needed.
	      (when (and ref retain-labels) (format " (%s)" ref))))
       ;; Mark transcoded line as an anchor, if needed.
       (if (not ref) loc
	 (format "<span id=\"coderef-%s\" class=\"coderef-off\">%s</span>"
		 ref loc)))
     num-start refs)))

(defun t-format-code (element info)
  "Format contents of ELEMENT as source code.
ELEMENT is either an example or a source block.  INFO is a plist
used as a communication channel."
  (let* ((lang (org-element-property :language element))
	 ;; Extract code and references.
	 (code-info (org-export-unravel-code element))
	 (code (car code-info))
	 (refs (cdr code-info))
	 ;; Does the source block contain labels?
	 (retain-labels (org-element-property :retain-labels element))
	 ;; Does it have line numbers?
	 (num-start (org-export-get-loc element info))
	 ;; Should lines be wrapped in code elements?
	 (wrap-lines (plist-get info :html-wrap-src-lines)))
    (t-do-format-code code lang refs retain-labels num-start wrap-lines)))


;;; Tables of Contents

(defun t-toc (depth info &optional scope)
  "Build a table of contents.
DEPTH is an integer specifying the depth of the table.  INFO is
a plist used as a communication channel.  Optional argument SCOPE
is an element defining the scope of the table.  Return the table
of contents as a string, or nil if it is empty."
  (let ((toc-entries
	 (mapcar (lambda (headline)
		   (cons (t--format-toc-headline headline info)
			 (org-export-get-relative-level headline info)))
		 (org-export-collect-headlines info depth scope))))
    (when toc-entries
      (let ((toc (concat "<div id=\"text-table-of-contents\" role=\"doc-toc\">"
			 (t--toc-text toc-entries)
			 "</div>\n")))
	(if scope toc
	  (let ((outer-tag (if (t--html5-fancy-p info)
			       "nav"
			     "div")))
	    (concat (format "<%s id=\"table-of-contents\" role=\"doc-toc\">\n" outer-tag)
		    (let ((top-level (plist-get info :html-toplevel-hlevel)))
		      (format "<h%d>%s</h%d>\n"
			      top-level
			      (t--translate "Table of Contents" info)
			      top-level))
		    toc
		    (format "</%s>\n" outer-tag))))))))

(defun t--toc-text (toc-entries)
  "Return innards of a table of contents, as a string.
TOC-ENTRIES is an alist where key is an entry title, as a string,
and value is its relative level, as an integer."
  (let* ((prev-level (1- (cdar toc-entries)))
	 (start-level prev-level))
    (concat
     (mapconcat
      (lambda (entry)
	(let ((headline (car entry))
	      (level (cdr entry)))
	  (concat
	   (let* ((cnt (- level prev-level))
		  (times (if (> cnt 0) (1- cnt) (- cnt))))
	     (setq prev-level level)
	     (concat
	      (t--make-string
	       times (cond ((> cnt 0) "\n<ul>\n<li>")
			   ((< cnt 0) "</li>\n</ul>\n")))
	      (if (> cnt 0) "\n<ul>\n<li>" "</li>\n<li>")))
	   headline)))
      toc-entries "")
     (t--make-string (- prev-level start-level) "</li>\n</ul>\n"))))

(defun t--format-toc-headline (headline info)
  "Return an appropriate table of contents entry for HEADLINE.
INFO is a plist used as a communication channel."
  (let* ((headline-number (org-export-get-headline-number headline info))
	 (todo (and (plist-get info :with-todo-keywords)
		    (let ((todo (org-element-property :todo-keyword headline)))
		      (and todo (org-export-data todo info)))))
	 (todo-type (and todo (org-element-property :todo-type headline)))
	 (priority (and (plist-get info :with-priority)
			(org-element-property :priority headline)))
	 (text (org-export-data-with-backend
		(org-export-get-alt-title headline info)
		(org-export-toc-entry-backend 'html)
		info))
	 (tags (and (eq (plist-get info :with-tags) t)
		    (org-export-get-tags headline info))))
    (format "<a href=\"#%s\">%s</a>"
	    ;; Label.
	    (t--reference headline info)
	    ;; Body.
	    (concat
	     (and (not (org-export-low-level-p headline info))
		  (org-export-numbered-headline-p headline info)
		  (concat (mapconcat #'number-to-string headline-number ".")
			  ". "))
	     (apply (plist-get info :html-format-headline-function)
		    todo todo-type priority text tags :section-number nil)))))

(defun t-list-of-listings (info)
  "Build a list of listings.
INFO is a plist used as a communication channel.  Return the list
of listings as a string, or nil if it is empty."
  (let ((lol-entries (org-export-collect-listings info)))
    (when lol-entries
      (concat "<div id=\"list-of-listings\">\n"
	      (let ((top-level (plist-get info :html-toplevel-hlevel)))
		(format "<h%d>%s</h%d>\n"
			top-level
			(t--translate "List of Listings" info)
			top-level))
	      "<div id=\"text-list-of-listings\">\n<ul>\n"
	      (let ((count 0)
		    (initial-fmt (format "<span class=\"listing-number\">%s</span>"
					 (t--translate "Listing %d:" info))))
		(mapconcat
		 (lambda (entry)
		   (let ((label (t--reference entry info t))
			 (title (org-trim
				 (org-export-data
				  (or (org-export-get-caption entry t)
				      (org-export-get-caption entry))
				  info))))
		     (concat
		      "<li>"
		      (if (not label)
			  (concat (format initial-fmt (cl-incf count))
				  " "
				  title)
			(format "<a href=\"#%s\">%s %s</a>"
				label
				(format initial-fmt (cl-incf count))
				title))
		      "</li>")))
		 lol-entries "\n"))
	      "\n</ul>\n</div>\n</div>"))))

(defun t-list-of-tables (info)
  "Build a list of tables.
INFO is a plist used as a communication channel.  Return the list
of tables as a string, or nil if it is empty."
  (let ((lol-entries (org-export-collect-tables info)))
    (when lol-entries
      (concat "<div id=\"list-of-tables\">\n"
	      (let ((top-level (plist-get info :html-toplevel-hlevel)))
		(format "<h%d>%s</h%d>\n"
			top-level
			(t--translate "List of Tables" info)
			top-level))
	      "<div id=\"text-list-of-tables\">\n<ul>\n"
	      (let ((count 0)
		    (initial-fmt (format "<span class=\"table-number\">%s</span>"
					 (t--translate "Table %d:" info))))
		(mapconcat
		 (lambda (entry)
		   (let ((label (t--reference entry info t))
			 (title (org-trim
				 (org-export-data
				  (or (org-export-get-caption entry t)
				      (org-export-get-caption entry))
				  info))))
		     (concat
		      "<li>"
		      (if (not label)
			  (concat (format initial-fmt (cl-incf count))
				  " "
				  title)
			(format "<a href=\"#%s\">%s %s</a>"
				label
				(format initial-fmt (cl-incf count))
				title))
		      "</li>")))
		 lol-entries "\n"))
	      "\n</ul>\n</div>\n</div>"))))


;;; Transcode Functions

;;;; Bold

(defun t-bold (_bold contents info)
  "Transcode BOLD from Org to HTML.
CONTENTS is the text with bold markup.  INFO is a plist holding
contextual information."
  (format (or (cdr (assq 'bold (plist-get info :html-text-markup-alist))) "%s")
	  contents))

;;;; Center Block

(defun t-center-block (_center-block contents _info)
  "Transcode a CENTER-BLOCK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (format "<div class=\"org-center\">\n%s</div>" contents))

;;;; Clock

(defun t-clock (clock _contents _info)
  "Transcode a CLOCK element from Org to HTML.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format "<p>
<span class=\"timestamp-wrapper\">
<span class=\"timestamp-kwd\">%s</span> <span class=\"timestamp\">%s</span>%s
</span>
</p>"
	  org-clock-string
	  (org-timestamp-translate (org-element-property :value clock))
	  (let ((time (org-element-property :duration clock)))
	    (and time (format " <span class=\"timestamp\">(%s)</span>" time)))))

;;;; Code

(defun t-code (code _contents info)
  "Transcode CODE from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (format (or (cdr (assq 'code (plist-get info :html-text-markup-alist))) "%s")
	  (t-encode-plain-text (org-element-property :value code))))

;;;; Drawer

(defun t-drawer (drawer contents info)
  "Transcode a DRAWER element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (funcall (plist-get info :html-format-drawer-function)
	   (org-element-property :drawer-name drawer)
	   contents))

;;;; Dynamic Block

(defun t-dynamic-block (_dynamic-block contents _info)
  "Transcode a DYNAMIC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information.  See `org-export-data'."
  contents)

;;;; Entity

(defun t-entity (entity _contents _info)
  "Transcode an ENTITY object from Org to HTML.
CONTENTS are the definition itself.  INFO is a plist holding
contextual information."
  (org-element-property :html entity))

;;;; Example Block

(defun t-example-block (example-block _contents info)
  "Transcode a EXAMPLE-BLOCK element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (let ((attributes (org-export-read-attribute :attr_html example-block)))
    (if (plist-get attributes :textarea)
	(t--textarea-block example-block)
      (format "<pre class=\"example\"%s>\n%s</pre>"
	      (let* ((reference (t--reference example-block info t)) ;; <yynt> 仅在显式 #+NAME 时才生成 ID
		     (a (t--make-attribute-string
			 (if (or (not reference) (plist-member attributes :id))
			     attributes
			   (plist-put attributes :id reference)))))
		(if (org-string-nw-p a) (concat " " a) ""))
	      (t-format-code example-block info)))))

;;;; Export Snippet

(defun t-export-snippet (export-snippet _contents _info)
  "Transcode a EXPORT-SNIPPET object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (when (eq (org-export-snippet-backend export-snippet) 'html)
    (org-element-property :value export-snippet)))

;;;; Export Block

(defun t-export-block (export-block _contents _info)
  "Transcode a EXPORT-BLOCK element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (when (string= (org-element-property :type export-block) "HTML")
    (org-remove-indentation (org-element-property :value export-block))))

;;;; Fixed Width

(defun t-fixed-width (fixed-width _contents _info)
  "Transcode a FIXED-WIDTH element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (format "<pre class=\"example\">\n%s</pre>"
	  (t-do-format-code
	   (org-remove-indentation
	    (org-element-property :value fixed-width)))))

;;;; Footnote Reference

(defun t-footnote-reference (footnote-reference _contents info)
  "Transcode a FOOTNOTE-REFERENCE element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (concat
   ;; Insert separator between two footnotes in a row.
   (let ((prev (org-export-get-previous-element footnote-reference info)))
     (when (eq (org-element-type prev) 'footnote-reference)
       (plist-get info :html-footnote-separator)))
   (let* ((n (org-export-get-footnote-number footnote-reference info))
	  (id (format "fnr.%d%s"
		      n
		      (if (org-export-footnote-first-reference-p
			   footnote-reference info)
			  ""
			".100"))))
     (format
      (plist-get info :html-footnote-format)
      (t--anchor
       id n (format " class=\"footref\" href=\"#fn.%d\" role=\"doc-backlink\"" n) info)))))

;;;; Headline

(defun t-headline (headline contents info)
  "Transcode a HEADLINE element from Org to HTML.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  (unless (org-element-property :footnote-section-p headline)
    (let* ((numberedp (org-export-numbered-headline-p headline info))
           (numbers (org-export-get-headline-number headline info))
           (level (+ (org-export-get-relative-level headline info)
                     (1- (plist-get info :html-toplevel-hlevel))))
           (todo (and (plist-get info :with-todo-keywords)
                      (let ((todo (org-element-property :todo-keyword headline)))
                        (and todo (org-export-data todo info)))))
           (todo-type (and todo (org-element-property :todo-type headline)))
           (priority (and (plist-get info :with-priority)
                          (org-element-property :priority headline)))
           (text (org-export-data (org-element-property :title headline) info))
           (tags (and (plist-get info :with-tags)
                      (org-export-get-tags headline info)))
           (full-text (funcall (plist-get info :html-format-headline-function)
                               todo todo-type priority text tags info))
           (contents (or contents ""))
	   (id (t--reference headline info))
	   (formatted-text
	    (if (plist-get info :html-self-link-headlines)
		(format "<a href=\"#%s\">%s</a>" id full-text)
	      full-text)))
      (if (org-export-low-level-p headline info)
          ;; This is a deep sub-tree: export it as a list item.
          (let* ((html-type (if numberedp "ol" "ul")))
	    (concat
	     (and (org-export-first-sibling-p headline info)
		  (apply #'format "<%s class=\"org-%s\">\n"
			 (make-list 2 html-type)))
	     (t-format-list-item
	      contents (if numberedp 'ordered 'unordered)
	      nil info nil
	      (concat (t--anchor id nil nil info) formatted-text)) "\n"
	     (and (org-export-last-sibling-p headline info)
		  (format "</%s>\n" html-type))))
	;; Standard headline.  Export it as a section.
        (let ((extra-class
	       (org-element-property :HTML_CONTAINER_CLASS headline))
	      (headline-class
	       (org-element-property :HTML_HEADLINE_CLASS headline))
              (first-content (car (org-element-contents headline))))
	  ;; <yynt> 此处移除了 headline 的外层 id
          (format "<%s class=\"%s\">%s%s</%s>\n"
                  (t--container headline info)
                  (concat (format "outline-%d" level)
                          (and extra-class " ")
                          extra-class)
                  (format "\n<h%d id=\"%s\"%s>%s</h%d>\n"
                          level
                          id
			  (if (not headline-class) ""
			    (format " class=\"%s\"" headline-class))
                          (concat
                           (and numberedp
                                (format
                                 "<span class=\"section-number-%d\">%s</span> "
                                 level
                                 (concat (mapconcat #'number-to-string numbers ".") ".")))
                           formatted-text)
                          level)
                  ;; When there is no section, pretend there is an
                  ;; empty one to get the correct <div
                  ;; class="outline-...> which is needed by
                  ;; `org-info.js'.
                  (if (eq (org-element-type first-content) 'section) contents
                    (concat (t-section first-content "" info) contents))
                  (t--container headline info)))))))

(defun t-format-headline-default-function
    (todo _todo-type priority text tags info)
  "Default format function for a headline.
See `t-format-headline-function' for details."
  (let ((todo (t--todo todo info))
	(priority (t--priority priority info))
	(tags (t--tags tags info)))
    (concat todo (and todo " ")
	    priority (and priority " ")
	    text
	    (and tags "&#xa0;&#xa0;&#xa0;") tags)))

(defun t--container (headline info)
  (or (org-element-property :HTML_CONTAINER headline)
      (if (= 1 (org-export-get-relative-level headline info))
	  (plist-get info :html-container)
	"div")))

;;;; Horizontal Rule

(defun t-horizontal-rule (_horizontal-rule _contents info)
  "Transcode an HORIZONTAL-RULE  object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (t-close-tag "hr" nil info))

;;;; Inline Src Block

(defun t-inline-src-block (inline-src-block _contents info)
  "Transcode an INLINE-SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (let* ((lang (org-element-property :language inline-src-block))
	 (code (t-fontify-code
		(org-element-property :value inline-src-block)
		lang))
	 (label
	  (let ((lbl (t--reference inline-src-block info t)))
	    (if (not lbl) "" (format " id=\"%s\"" lbl)))))
    (format "<code class=\"src src-%s\"%s>%s</code>" lang label code)))

;;;; Inlinetask

(defun t-inlinetask (inlinetask contents info)
  "Transcode an INLINETASK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (let* ((todo (and (plist-get info :with-todo-keywords)
		    (let ((todo (org-element-property :todo-keyword inlinetask)))
		      (and todo (org-export-data todo info)))))
	 (todo-type (and todo (org-element-property :todo-type inlinetask)))
	 (priority (and (plist-get info :with-priority)
			(org-element-property :priority inlinetask)))
	 (text (org-export-data (org-element-property :title inlinetask) info))
	 (tags (and (plist-get info :with-tags)
		    (org-export-get-tags inlinetask info))))
    (funcall (plist-get info :html-format-inlinetask-function)
	     todo todo-type priority text tags contents info)))

(defun t-format-inlinetask-default-function
    (todo todo-type priority text tags contents info)
  "Default format function for inlinetasks.
See `t-format-inlinetask-function' for details."
  (format "<div class=\"inlinetask\">\n<b>%s</b>%s\n%s</div>"
	  (t-format-headline-default-function
	   todo todo-type priority text tags info)
	  (t-close-tag "br" nil info)
	  contents))

;;;; Italic

(defun t-italic (_italic contents info)
  "Transcode ITALIC from Org to HTML.
CONTENTS is the text with italic markup.  INFO is a plist holding
contextual information."
  (format
   (or (cdr (assq 'italic (plist-get info :html-text-markup-alist))) "%s")
   contents))

;;;; Item

(defun t-checkbox (checkbox info)
  "Format CHECKBOX into HTML.
INFO is a plist holding contextual information.  See
`t-checkbox-type' for customization options."
  (cdr (assq checkbox
	     (cdr (assq (plist-get info :html-checkbox-type)
			t-checkbox-types)))))

(defun t-format-list-item (contents type checkbox info
					   &optional term-counter-id
					   headline)
  "Format a list item into HTML."
  (let ((class (if checkbox
		   (format " class=\"%s\""
			   (symbol-name checkbox)) ""))
	(checkbox (concat (t-checkbox checkbox info)
			  (and checkbox " ")))
	(br (t-close-tag "br" nil info))
	(extra-newline (if (and (org-string-nw-p contents) headline) "\n" "")))
    (concat
     (pcase type
       (`ordered
	(let* ((counter term-counter-id)
	       (extra (if counter (format " value=\"%s\"" counter) "")))
	  (concat
	   (format "<li%s%s>" class extra)
	   (when headline (concat headline br)))))
       (`unordered
	(let* ((id term-counter-id)
	       (extra (if id (format " id=\"%s\"" id) "")))
	  (concat
	   (format "<li%s%s>" class extra)
	   (when headline (concat headline br)))))
       (`descriptive
	(let* ((term term-counter-id))
	  (setq term (or term "(no term)"))
	  ;; Check-boxes in descriptive lists are associated to tag.
	  (concat (format "<dt%s>%s</dt>"
			  class (concat checkbox term))
		  "<dd>"))))
     (unless (eq type 'descriptive) checkbox)
     extra-newline
     (and (org-string-nw-p contents) (org-trim contents))
     extra-newline
     (pcase type
       (`ordered "</li>")
       (`unordered "</li>")
       (`descriptive "</dd>")))))

(defun t-item (item contents info)
  "Transcode an ITEM element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (let* ((plain-list (org-export-get-parent item))
	 (type (org-element-property :type plain-list))
	 (counter (org-element-property :counter item))
	 (checkbox (org-element-property :checkbox item))
	 (tag (let ((tag (org-element-property :tag item)))
		(and tag (org-export-data tag info)))))
    (t-format-list-item
     contents type checkbox info (or tag counter))))

;;;; Keyword

(defun t-keyword (keyword _contents info)
  "Transcode a KEYWORD element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (let ((key (org-element-property :key keyword))
	(value (org-element-property :value keyword)))
    (cond
     ((string= key "HTML") value)
     ((string= key "TOC")
      (let ((case-fold-search t))
	(cond
	 ((string-match "\\<headlines\\>" value)
	  (let ((depth (and (string-match "\\<[0-9]+\\>" value)
			    (string-to-number (match-string 0 value))))
		(scope
		 (cond
		  ((string-match ":target +\\(\".+?\"\\|\\S-+\\)" value) ;link
		   (org-export-resolve-link
		    (org-strip-quotes (match-string 1 value)) info))
		  ((string-match-p "\\<local\\>" value) keyword)))) ;local
	    (t-toc depth info scope)))
	 ((string= "listings" value) (t-list-of-listings info))
	 ((string= "tables" value) (t-list-of-tables info))))))))

;;;; Latex Environment

(defun t-format-latex (latex-frag processing-type info)
  "Format a LaTeX fragment LATEX-FRAG into HTML.
PROCESSING-TYPE designates the tool used for conversion.  It can
be `mathjax', `verbatim', `html', nil, t or symbols in
`org-preview-latex-process-alist', e.g., `dvipng', `dvisvgm' or
`imagemagick'.  See `t-with-latex' for more information.
INFO is a plist containing export properties."
  (let ((cache-relpath "") (cache-dir ""))
    (unless (or (eq processing-type 'mathjax)
                (eq processing-type 'html))
      (let ((bfn (or (buffer-file-name)
		     (make-temp-name
		      (expand-file-name "latex" temporary-file-directory))))
	    (latex-header
	     (let ((header (plist-get info :latex-header)))
	       (and header
		    (concat (mapconcat
			     (lambda (line) (concat "#+LATEX_HEADER: " line))
			     (org-split-string header "\n")
			     "\n")
			    "\n")))))
	(setq cache-relpath
	      (concat (file-name-as-directory org-preview-latex-image-directory)
		      (file-name-sans-extension
		       (file-name-nondirectory bfn)))
	      cache-dir (file-name-directory bfn))
	;; Re-create LaTeX environment from original buffer in
	;; temporary buffer so that dvipng/imagemagick can properly
	;; turn the fragment into an image.
	(setq latex-frag (concat latex-header latex-frag))))
    (with-temp-buffer
      (insert latex-frag)
      (org-format-latex cache-relpath nil nil cache-dir nil
			"Creating LaTeX Image..." nil processing-type)
      (buffer-string))))

(defun t--wrap-latex-environment (contents _ &optional caption label)
  "Wrap CONTENTS string within appropriate environment for equations.
When optional arguments CAPTION and LABEL are given, use them for
caption and \"id\" attribute."
  (format "\n<div%s class=\"equation-container\">\n%s%s\n</div>"
          ;; ID.
          (if (org-string-nw-p label) (format " id=\"%s\"" label) "")
          ;; Contents.
          (format "<span class=\"equation\">\n%s\n</span>" contents)
          ;; Caption.
          (if (not (org-string-nw-p caption)) ""
            (format "\n<span class=\"equation-label\">\n%s\n</span>"
                    caption))))

(defun t--math-environment-p (element &optional _)
  "Non-nil when ELEMENT is a LaTeX math environment.
Math environments match the regular expression defined in
`org-latex-math-environments-re'.  This function is meant to be
used as a predicate for `org-export-get-ordinal' or a value to
`t-standalone-image-predicate'."
  (string-match-p org-latex-math-environments-re
                  (org-element-property :value element)))

(defun t--latex-environment-numbered-p (element)
  "Non-nil when ELEMENT contains a numbered LaTeX math environment.
Starred and \"displaymath\" environments are not numbered."
  (not (string-match-p "\\`[ \t]*\\\\begin{\\(.*\\*\\|displaymath\\)}"
		       (org-element-property :value element))))

(defun t--unlabel-latex-environment (latex-frag)
  "Change environment in LATEX-FRAG string to an unnumbered one.
For instance, change an `equation' environment to `equation*'."
  (replace-regexp-in-string
   "\\`[ \t]*\\\\begin{\\([^*]+?\\)}"
   "\\1*"
   (replace-regexp-in-string "^[ \t]*\\\\end{\\([^*]+?\\)}[ \r\t\n]*\\'"
			     "\\1*"
			     latex-frag nil nil 1)
   nil nil 1))

(defun t-latex-environment (latex-environment _contents info)
  "Transcode a LATEX-ENVIRONMENT element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (let ((processing-type (plist-get info :with-latex))
	(latex-frag (org-remove-indentation
		     (org-element-property :value latex-environment)))
        (attributes (org-export-read-attribute :attr_html latex-environment))
        (label (t--reference latex-environment info t))
        (caption (and (t--latex-environment-numbered-p latex-environment)
		      (number-to-string
		       (org-export-get-ordinal
			latex-environment info nil
			(lambda (l _)
			  (and (t--math-environment-p l)
			       (t--latex-environment-numbered-p l))))))))
    (cond
     ((memq processing-type '(t mathjax))
      (t-format-latex
       (if (org-string-nw-p label)
	   (replace-regexp-in-string "\\`.*"
				     (format "\\&\n\\\\label{%s}" label)
				     latex-frag)
	 latex-frag)
       'mathjax info))
     ((assq processing-type org-preview-latex-process-alist)
      (let ((formula-link
             (t-format-latex
              (t--unlabel-latex-environment latex-frag)
              processing-type info)))
        (when (and formula-link (string-match "file:\\([^]]*\\)" formula-link))
          (let ((source (org-export-file-uri (match-string 1 formula-link))))
	    (t--wrap-latex-environment
	     (t--format-image source attributes info)
	     info caption label)))))
     (t (t--wrap-latex-environment latex-frag info caption label)))))

;;;; Latex Fragment

(defun t-latex-fragment (latex-fragment _contents info)
  "Transcode a LATEX-FRAGMENT object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (let ((latex-frag (org-element-property :value latex-fragment))
	(processing-type (plist-get info :with-latex)))
    (cond
     ((memq processing-type '(t mathjax))
      (t-format-latex latex-frag 'mathjax info))
     ((memq processing-type '(t html))
      (t-format-latex latex-frag 'html info))
     ((assq processing-type org-preview-latex-process-alist)
      (let ((formula-link
	     (t-format-latex latex-frag processing-type info)))
	(when (and formula-link (string-match "file:\\([^]]*\\)" formula-link))
	  (let ((source (org-export-file-uri (match-string 1 formula-link))))
	    (t--format-image source nil info)))))
     (t latex-frag))))

;;;; Line Break

(defun t-line-break (_line-break _contents info)
  "Transcode a LINE-BREAK object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (concat (t-close-tag "br" nil info) "\n"))

;;;; Link

(defun t-image-link-filter (data _backend info)
  (org-export-insert-image-links data info t-inline-image-rules))

(defun t-inline-image-p (link info)
  "Non-nil when LINK is meant to appear as an image.
INFO is a plist used as a communication channel.  LINK is an
inline image when it has no description and targets an image
file (see `t-inline-image-rules' for more information), or
if its description is a single link targeting an image file."
  (if (not (org-element-contents link))
      (org-export-inline-image-p
       link (plist-get info :html-inline-image-rules))
    (not
     (let ((link-count 0))
       (org-element-map (org-element-contents link)
	   (cons 'plain-text org-element-all-objects)
	 (lambda (obj)
	   (pcase (org-element-type obj)
	     (`plain-text (org-string-nw-p obj))
	     (`link (if (= link-count 1) t
		      (cl-incf link-count)
		      (not (org-export-inline-image-p
			    obj (plist-get info :html-inline-image-rules)))))
	     (_ t)))
         info t)))))

(defvar t-standalone-image-predicate)
(defun t-standalone-image-p (element info)
  "Non-nil if ELEMENT is a standalone image.

INFO is a plist holding contextual information.

An element or object is a standalone image when

  - its type is `paragraph' and its sole content, save for white
    spaces, is a link that qualifies as an inline image;

  - its type is `link' and its containing paragraph has no other
    content save white spaces.

Bind `t-standalone-image-predicate' to constrain paragraph
further.  For example, to check for only captioned standalone
images, set it to:

  (lambda (paragraph) (org-element-property :caption paragraph))"
  (let ((paragraph (pcase (org-element-type element)
		     (`paragraph element)
		     (`link (org-export-get-parent element)))))
    (and (eq (org-element-type paragraph) 'paragraph)
	 (or (not (and (boundp 't-standalone-image-predicate)
                       (fboundp t-standalone-image-predicate)))
	     (funcall t-standalone-image-predicate paragraph))
	 (catch 'exit
	   (let ((link-count 0))
	     (org-element-map (org-element-contents paragraph)
		 (cons 'plain-text org-element-all-objects)
	       (lambda (obj)
		 (when (pcase (org-element-type obj)
			 (`plain-text (org-string-nw-p obj))
			 (`link (or (> (cl-incf link-count) 1)
				    (not (t-inline-image-p obj info))))
			 (_ t))
		   (throw 'exit nil)))
	       info nil 'link)
	     (= link-count 1))))))

(defun t-link (link desc info)
  "Transcode a LINK object from Org to HTML.
DESC is the description part of the link, or the empty string.
INFO is a plist holding contextual information.  See
`org-export-data'."
  (let* ((html-ext (plist-get info :html-extension))
	 (dot (when (> (length html-ext) 0) "."))
	 (link-org-files-as-html-maybe
	  (lambda (raw-path info)
	    ;; Treat links to `file.org' as links to `file.html', if
	    ;; needed.  See `t-link-org-files-as-html'.
	    (cond
	     ((and (plist-get info :html-link-org-files-as-html)
		   (string= ".org"
			    (downcase (file-name-extension raw-path "."))))
	      (concat (file-name-sans-extension raw-path) dot html-ext))
	     (t raw-path))))
	 (type (org-element-property :type link))
	 (raw-path (org-element-property :path link))
	 ;; Ensure DESC really exists, or set it to nil.
	 (desc (org-string-nw-p desc))
	 (path
	  (cond
	   ((member type '("http" "https" "ftp" "mailto" "news"))
	    (url-encode-url (concat type ":" raw-path)))
	   ((string= "file" type)
	    ;; During publishing, turn absolute file names belonging
	    ;; to base directory into relative file names.  Otherwise,
	    ;; append "file" protocol to absolute file name.
	    (setq raw-path
		  (org-export-file-uri
		   (org-publish-file-relative-name raw-path info)))
	    ;; Possibly append `:html-link-home' to relative file
	    ;; name.
	    (let ((home (and (plist-get info :html-link-home)
			     (org-trim (plist-get info :html-link-home)))))
	      (when (and home
			 (plist-get info :html-link-use-abs-url)
			 (file-name-absolute-p raw-path))
		(setq raw-path (concat (file-name-as-directory home) raw-path))))
	    ;; Maybe turn ".org" into ".html".
	    (setq raw-path (funcall link-org-files-as-html-maybe raw-path info))
	    ;; Add search option, if any.  A search option can be
	    ;; relative to a custom-id, a headline title, a name or
	    ;; a target.
	    (let ((option (org-element-property :search-option link)))
	      (if (not option) raw-path
		(let ((path (org-element-property :path link)))
		  (concat raw-path
			  "#"
			  (org-publish-resolve-external-link option path t))))))
	   (t raw-path)))
	 (attributes-plist
	  (org-combine-plists
	   ;; Extract attributes from parent's paragraph.  HACK: Only
	   ;; do this for the first link in parent (inner image link
	   ;; for inline images).  This is needed as long as
	   ;; attributes cannot be set on a per link basis.
	   (let* ((parent (org-export-get-parent-element link))
		  (link (let ((container (org-export-get-parent link)))
			  (if (and (eq 'link (org-element-type container))
				   (t-inline-image-p link info))
			      container
			    link))))
	     (and (eq link (org-element-map parent 'link #'identity info t))
		  (org-export-read-attribute :attr_html parent)))
	   ;; Also add attributes from link itself.  Currently, those
	   ;; need to be added programmatically before `t-link'
	   ;; is invoked, for example, by backends building upon HTML
	   ;; export.
	   (org-export-read-attribute :attr_html link)))
	 (attributes
	  (let ((attr (t--make-attribute-string attributes-plist)))
	    (if (org-string-nw-p attr) (concat " " attr) ""))))
    (cond
     ;; Link type is handled by a special function.
     ((org-export-custom-protocol-maybe link desc 'yyhtml info))
     ;; Image file.
     ((and (plist-get info :html-inline-images)
	   (org-export-inline-image-p
	    link (plist-get info :html-inline-image-rules)))
      (t--format-image path attributes-plist info))
     ;; Radio target: Transcode target's contents and use them as
     ;; link's description.
     ((string= type "radio")
      (let ((destination (org-export-resolve-radio-link link info)))
	(if (not destination) desc
	  (format "<a href=\"#%s\"%s>%s</a>"
		  ;; (org-export-get-reference destination info)
		  ;; <yynt> 修改为 t--reference
		  ;; https://egh0bww1.com/posts/2023-02-05-28-org-html5-export-sequel/
		  (t--reference destination info)
		  attributes
		  desc))))
     ;; Links pointing to a headline: Find destination and build
     ;; appropriate referencing command.
     ((member type '("custom-id" "fuzzy" "id"))
      (let ((destination (if (string= type "fuzzy")
			     (org-export-resolve-fuzzy-link link info)
			   (org-export-resolve-id-link link info))))
	(pcase (org-element-type destination)
	  ;; ID link points to an external file.
	  (`plain-text
	   (let ((fragment (concat "ID-" path))
		 ;; Treat links to ".org" files as ".html", if needed.
		 (path (funcall link-org-files-as-html-maybe
				destination info)))
	     (format "<a href=\"%s#%s\"%s>%s</a>"
		     path fragment attributes (or desc destination))))
	  ;; Fuzzy link points nowhere.
	  (`nil
	   (format "<i>%s</i>"
		   (or desc
		       (org-export-data
			(org-element-property :raw-link link) info))))
	  ;; Link points to a headline.
	  (`headline
	   (let ((href (t--reference destination info))
		 ;; What description to use?
		 (desc
		  ;; Case 1: Headline is numbered and LINK has no
		  ;; description.  Display section number.
		  (if (and (org-export-numbered-headline-p destination info)
			   (not desc))
		      (mapconcat #'number-to-string
				 (org-export-get-headline-number
				  destination info) ".")
		    ;; Case 2: Either the headline is un-numbered or
		    ;; LINK has a custom description.  Display LINK's
		    ;; description or headline's title.
		    (or desc
			(org-export-data
			 (org-element-property :title destination) info)))))
	     (format "<a href=\"#%s\"%s>%s</a>" href attributes desc)))
	  ;; Fuzzy link points to a target or an element.
	  (_
           (if (and destination
                    (memq (plist-get info :with-latex) '(mathjax t))
                    (eq 'latex-environment (org-element-type destination))
                    (eq 'math (org-latex--environment-type destination)))
               ;; Caption and labels are introduced within LaTeX
	       ;; environment.  Use "ref" or "eqref" macro, depending on user
               ;; preference to refer to those in the document.
               (format (plist-get info :html-equation-reference-format)
                       (t--reference destination info))
             (let* ((ref (t--reference destination info))
                    (t-standalone-image-predicate
                     #'t--has-caption-p)
                    (counter-predicate
                     (if (eq 'latex-environment (org-element-type destination))
                         #'t--math-environment-p
                       #'t--has-caption-p))
                    (number
		     (cond
		      (desc nil)
		      ((t-standalone-image-p destination info)
		       (org-export-get-ordinal
			(org-element-map destination 'link #'identity info t)
			info 'link 't-standalone-image-p))
		      (t (org-export-get-ordinal
			  destination info nil counter-predicate))))
                    (desc
		     (cond (desc)
			   ((not number) "No description for this link")
			   ((numberp number) (number-to-string number))
			   (t (mapconcat #'number-to-string number ".")))))
               (format "<a href=\"#%s\"%s>%s</a>" ref attributes desc)))))))
     ;; Coderef: replace link with the reference name or the
     ;; equivalent line number.
     ((string= type "coderef")
      (let ((fragment (concat "coderef-" (t-encode-plain-text path))))
	(format "<a href=\"#%s\" %s%s>%s</a>"
		fragment
		(format "class=\"coderef\" onmouseover=\"CodeHighlightOn(this, \
'%s');\" onmouseout=\"CodeHighlightOff(this, '%s');\""
			fragment fragment)
		attributes
		(format (org-export-get-coderef-format path desc)
			(org-export-resolve-coderef path info)))))
     ;; External link with a description part.
     ((and path desc)
      (format "<a href=\"%s\"%s>%s</a>"
	      (t-encode-plain-text path)
	      attributes
	      desc))
     ;; External link without a description part.
     (path
      (let ((path (t-encode-plain-text path)))
	(format "<a href=\"%s\"%s>%s</a>" path attributes path)))
     ;; No path, only description.  Try to do something useful.
     (t
      (format "<i>%s</i>" desc)))))

;;;; Node Property

(defun t-node-property (node-property _contents _info)
  "Transcode a NODE-PROPERTY element from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (format "%s:%s"
          (org-element-property :key node-property)
          (let ((value (org-element-property :value node-property)))
            (if value (concat " " value) ""))))

;;;; Paragraph

(defun t-paragraph (paragraph contents info)
  "Transcode a PARAGRAPH element from Org to HTML.
CONTENTS is the contents of the paragraph, as a string.  INFO is
the plist used as a communication channel."
  (let* ((parent (org-export-get-parent paragraph))
	 (parent-type (org-element-type parent))
	 (style '((footnote-definition " class=\"footpara\"")
		  (org-data " class=\"footpara\"")))
	 (attributes (t--make-attribute-string
		      (org-export-read-attribute :attr_html paragraph)))
	 (extra (or (cadr (assq parent-type style)) "")))
    (cond
     ((and (eq parent-type 'item)
	   (not (org-export-get-previous-element paragraph info))
	   (let ((followers (org-export-get-next-element paragraph info 2)))
	     (and (not (cdr followers))
		  (memq (org-element-type (car followers)) '(nil plain-list)))))
      ;; First paragraph in an item has no tag if it is alone or
      ;; followed, at most, by a sub-list.
      contents)
     ((t-standalone-image-p paragraph info)
      ;; Standalone image.
      (let ((caption
	     (let ((raw (org-export-data
			 (org-export-get-caption paragraph) info))
		   (t-standalone-image-predicate
		    #'t--has-caption-p))
	       (if (not (org-string-nw-p raw)) raw
		 (concat "<span class=\"figure-number\">"
			 (format (t--translate "Figure %d:" info)
				 (org-export-get-ordinal
				  (org-element-map paragraph 'link
				    #'identity info t)
				  info nil #'t-standalone-image-p))
			 " </span>"
			 raw))))
	    (label (t--reference paragraph info t))) ; <yynt> 仅允许命名时才生成 figure 的 id
	(t--wrap-image contents info caption label)))
     ;; Regular paragraph.
     (t (format "<p%s%s>\n%s</p>"
		(if (org-string-nw-p attributes)
		    (concat " " attributes) "")
		extra contents)))))

;;;; Plain List

(defun t-plain-list (plain-list contents _info)
  "Transcode a PLAIN-LIST element from Org to HTML.
CONTENTS is the contents of the list.  INFO is a plist holding
contextual information."
  (let* ((type (pcase (org-element-property :type plain-list)
		 (`ordered "ol")
		 (`unordered "ul")
		 (`descriptive "dl")
		 (other (error "Unknown HTML list type: %s" other))))
	 (class (format "org-%s" type))
	 (attributes (org-export-read-attribute :attr_html plain-list)))
    (format "<%s %s>\n%s</%s>"
	    type
	    (t--make-attribute-string
	     (plist-put attributes :class
			(org-trim
			 (mapconcat #'identity
				    (list class (plist-get attributes :class))
				    " "))))
	    contents
	    type)))

;;;; Plain Text

(defun t-convert-special-strings (string)
  "Convert special characters in STRING to HTML."
  (dolist (a t-special-string-regexps string)
    (let ((re (car a))
	  (rpl (cdr a)))
      (setq string (replace-regexp-in-string re rpl string t)))))

(defun t-encode-plain-text (text)
  "Convert plain text characters from TEXT to HTML equivalent.
Possible conversions are set in `t-protect-char-alist'."
  (dolist (pair t-protect-char-alist text)
    (setq text (replace-regexp-in-string (car pair) (cdr pair) text t t))))

(defun t-plain-text (text info)
  "Transcode a TEXT string from Org to HTML.
TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  (let ((output text))
    ;; Protect following characters: <, >, &.
    (setq output (t-encode-plain-text output))
    ;; Handle smart quotes.  Be sure to provide original string since
    ;; OUTPUT may have been modified.
    (when (plist-get info :with-smart-quotes)
      (setq output (org-export-activate-smart-quotes output :html info text)))
    ;; Handle special strings.
    (when (plist-get info :with-special-strings)
      (setq output (t-convert-special-strings output)))
    ;; Handle break preservation if required.
    (when (plist-get info :preserve-breaks)
      (setq output
	    (replace-regexp-in-string
	     "\\(\\\\\\\\\\)?[ \t]*\n"
	     (concat (t-close-tag "br" nil info) "\n") output)))
    ;; Return value.
    output))


;; Planning

(defun t-planning (planning _contents info)
  "Transcode a PLANNING element from Org to HTML.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format
   "<p><span class=\"timestamp-wrapper\">%s</span></p>"
   (org-trim
    (mapconcat
     (lambda (pair)
       (let ((timestamp (cdr pair)))
	 (when timestamp
	   (let ((string (car pair)))
	     (format "<span class=\"timestamp-kwd\">%s</span> \
<span class=\"timestamp\">%s</span> "
		     string
		     (t-plain-text (org-timestamp-translate timestamp)
					  info))))))
     `((,org-closed-string . ,(org-element-property :closed planning))
       (,org-deadline-string . ,(org-element-property :deadline planning))
       (,org-scheduled-string . ,(org-element-property :scheduled planning)))
     ""))))

;;;; Property Drawer

(defun t-property-drawer (_property-drawer contents _info)
  "Transcode a PROPERTY-DRAWER element from Org to HTML.
CONTENTS holds the contents of the drawer.  INFO is a plist
holding contextual information."
  (and (org-string-nw-p contents)
       (format "<pre class=\"example\">\n%s</pre>" contents)))

;;;; Quote Block

(defun t-quote-block (quote-block contents info)
  "Transcode a QUOTE-BLOCK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (format "<blockquote%s>\n%s</blockquote>"
	  (let* ((reference (t--reference quote-block info t))
		 (attributes (org-export-read-attribute :attr_html quote-block))
		 (a (t--make-attribute-string
		     (if (or (not reference) (plist-member attributes :id))
			 attributes
		       (plist-put attributes :id reference)))))
	    (if (org-string-nw-p a) (concat " " a) ""))
	  contents))

;;;; Section

(defun t-section (section contents info)
  "Transcode a SECTION element from Org to HTML.
CONTENTS holds the contents of the section.  INFO is a plist
holding contextual information."
  (let ((parent (org-export-get-parent-headline section)))
    ;; Before first headline: no container, just return CONTENTS.
    (if (not parent) contents
      ;; Get div's class and id references.
      (let* ((class-num (+ (org-export-get-relative-level parent info)
			   (1- (plist-get info :html-toplevel-hlevel))))
	     (section-number
	      (and (org-export-numbered-headline-p parent info)
		   (mapconcat
		    #'number-to-string
		    (org-export-get-headline-number parent info) "-"))))
        ;; Build return value.
	;; <yynt> 此处可能不需要 id
	(format "<div class=\"outline-text-%d\">\n%s</div>\n"
		class-num
		(or contents ""))))))

;;;; Radio Target

(defun t-radio-target (radio-target text info)
  "Transcode a RADIO-TARGET object from Org to HTML.
TEXT is the text of the target.  INFO is a plist holding
contextual information."
  (let ((ref (t--reference radio-target info)))
    (t--anchor ref text nil info)))

;;;; Special Block

(defun t-special-block (special-block contents info)
  "Transcode a SPECIAL-BLOCK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (let* ((block-type (org-element-property :type special-block))
         (html5-fancy (and (t--html5-fancy-p info)
                           (member block-type t-html5-elements)))
         (attributes (org-export-read-attribute :attr_html special-block)))
    (unless html5-fancy
      (let ((class (plist-get attributes :class)))
        (setq attributes (plist-put attributes :class
                                    (if class (concat class " " block-type)
                                      block-type)))))
    (let* ((contents (or contents ""))
	   (reference (t--reference special-block info t)) ;; <yynt> 仅命名才有 id
	   (a (t--make-attribute-string
	       (if (or (not reference) (plist-member attributes :id))
		   attributes
		 (plist-put attributes :id reference))))
	   (str (if (org-string-nw-p a) (concat " " a) "")))
      (if html5-fancy
	  (format "<%s%s>\n%s</%s>" block-type str contents block-type)
	(format "<div%s>\n%s\n</div>" str contents)))))

;;;; Src Block

(defun t-src-block (src-block _contents info)
  "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (if (org-export-read-attribute :attr_html src-block :textarea)
      (t--textarea-block src-block)
    (let* ((lang (org-element-property :language src-block))
	   (code (t-format-code src-block info))
	   (label (let ((lbl (t--reference src-block info t)))
		    (if lbl (format " id=\"%s\"" lbl) "")))
	   (klipsify  (and  (plist-get info :html-klipsify-src)
                            (member lang '("javascript" "js"
					   "ruby" "scheme" "clojure" "php" "html")))))
      (if (not lang) (format "<pre class=\"example\"%s>\n%s</pre>" label code)
	(format "<div class=\"org-src-container\">\n%s%s\n</div>"
		;; Build caption.
		(let ((caption (org-export-get-caption src-block)))
		  (if (not caption) ""
		    (let ((listing-number
			   (format
			    "<span class=\"listing-number\">%s </span>"
			    (format
			     (t--translate "Listing %d:" info)
			     (org-export-get-ordinal
			      src-block info nil #'t--has-caption-p)))))
		      (format "<label class=\"org-src-name\">%s%s</label>"
			      listing-number
			      (org-trim (org-export-data caption info))))))
		;; Contents.
		(if klipsify
		    (format "<pre><code class=\"src src-%s\"%s%s>%s</code></pre>"
			    lang
			    label
			    (if (string= lang "html")
				" data-editor-type=\"html\""
			      "")
			    code)
		  (format "<pre class=\"src src-%s\"%s>\n%s</pre>" ; <yynt> 添加换行符
                          lang label code)))))))

;;;; Statistics Cookie

(defun t-statistics-cookie (statistics-cookie _contents _info)
  "Transcode a STATISTICS-COOKIE object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (let ((cookie-value (org-element-property :value statistics-cookie)))
    (format "<code>%s</code>" cookie-value)))

;;;; Strike-Through

(defun t-strike-through (_strike-through contents info)
  "Transcode STRIKE-THROUGH from Org to HTML.
CONTENTS is the text with strike-through markup.  INFO is a plist
holding contextual information."
  (format
   (or (cdr (assq 'strike-through (plist-get info :html-text-markup-alist)))
       "%s")
   contents))

;;;; Subscript

(defun t-subscript (_subscript contents _info)
  "Transcode a SUBSCRIPT object from Org to HTML.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (format "<sub>%s</sub>" contents))

;;;; Superscript

(defun t-superscript (_superscript contents _info)
  "Transcode a SUPERSCRIPT object from Org to HTML.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (format "<sup>%s</sup>" contents))

;;;; Table Cell

(defun t-table-cell (table-cell contents info)
  "Transcode a TABLE-CELL element from Org to HTML.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (let* ((table-row (org-export-get-parent table-cell))
	 (table (org-export-get-parent-table table-cell))
	 (cell-attrs
	  (if (not (plist-get info :html-table-align-individual-fields)) ""
	    (format (if (and (boundp 't-format-table-no-css)
			     t-format-table-no-css)
			" align=\"%s\"" " class=\"org-%s\"")
		    (org-export-table-cell-alignment table-cell info)))))
    (when (or (not contents) (string= "" (org-trim contents)))
      (setq contents "&#xa0;"))
    (cond
     ((and (org-export-table-has-header-p table info)
	   (= 1 (org-export-table-row-group table-row info)))
      (let ((header-tags (plist-get info :html-table-header-tags)))
	(concat "\n" (format (car header-tags) "col" cell-attrs)
		contents
		(cdr header-tags))))
     ((and (plist-get info :html-table-use-header-tags-for-first-column)
	   (zerop (cdr (org-export-table-cell-address table-cell info))))
      (let ((header-tags (plist-get info :html-table-header-tags)))
	(concat "\n" (format (car header-tags) "row" cell-attrs)
		contents
		(cdr header-tags))))
     (t (let ((data-tags (plist-get info :html-table-data-tags)))
	  (concat "\n" (format (car data-tags) cell-attrs)
		  contents
		  (cdr data-tags)))))))

;;;; Table Row

(defun t-table-row (table-row contents info)
  "Transcode a TABLE-ROW element from Org to HTML.
CONTENTS is the contents of the row.  INFO is a plist used as a
communication channel."
  ;; Rules are ignored since table separators are deduced from
  ;; borders of the current row.
  (when (eq (org-element-property :type table-row) 'standard)
    (let* ((group (org-export-table-row-group table-row info))
	   (number (org-export-table-row-number table-row info))
	   (start-group-p
	    (org-export-table-row-starts-rowgroup-p table-row info))
	   (end-group-p
	    (org-export-table-row-ends-rowgroup-p table-row info))
	   (topp (and (equal start-group-p '(top))
		      (equal end-group-p '(below top))))
	   (bottomp (and (equal start-group-p '(above))
			 (equal end-group-p '(bottom above))))
           (row-open-tag
            (pcase (plist-get info :html-table-row-open-tag)
              ((and accessor (pred functionp))
               (funcall accessor
			number group start-group-p end-group-p topp bottomp))
	      (accessor accessor)))
           (row-close-tag
            (pcase (plist-get info :html-table-row-close-tag)
              ((and accessor (pred functionp))
               (funcall accessor
			number group start-group-p end-group-p topp bottomp))
	      (accessor accessor)))
	   (group-tags
	    (cond
	     ;; Row belongs to second or subsequent groups.
	     ((not (= 1 group)) '("<tbody>" . "\n</tbody>"))
	     ;; Row is from first group.  Table has >=1 groups.
	     ((org-export-table-has-header-p
	       (org-export-get-parent-table table-row) info)
	      '("<thead>" . "\n</thead>"))
	     ;; Row is from first and only group.
	     (t '("<tbody>" . "\n</tbody>")))))
      (concat (and start-group-p (car group-tags))
	      (concat "\n"
		      row-open-tag
		      contents
		      "\n"
		      row-close-tag)
	      (and end-group-p (cdr group-tags))))))

;;;; Table

(defun t-table-first-row-data-cells (table info)
  "Transcode the first row of TABLE.
INFO is a plist used as a communication channel."
  (let ((table-row
	 (org-element-map table 'table-row
	   (lambda (row)
	     (unless (eq (org-element-property :type row) 'rule) row))
	   info 'first-match))
	(special-column-p (org-export-table-has-special-column-p table)))
    (if (not special-column-p) (org-element-contents table-row)
      (cdr (org-element-contents table-row)))))

(defun t-table--table.el-table (table _info)
  "Format table.el tables into HTML.
INFO is a plist used as a communication channel."
  (when (eq (org-element-property :type table) 'table.el)
    (require 'table)
    (let ((outbuf (with-current-buffer
		      (get-buffer-create "*org-export-table*")
		    (erase-buffer) (current-buffer))))
      (with-temp-buffer
	(insert (org-element-property :value table))
	(goto-char 1)
	(re-search-forward "^[ \t]*|[^|]" nil t)
	(table-generate-source 'html outbuf))
      (with-current-buffer outbuf
	(prog1 (org-trim (buffer-string))
	  (kill-buffer) )))))

(defun t-table (table contents info)
  "Transcode a TABLE element from Org to HTML.
CONTENTS is the contents of the table.  INFO is a plist holding
contextual information."
  (if (eq (org-element-property :type table) 'table.el)
      ;; "table.el" table.  Convert it using appropriate tools.
      (t-table--table.el-table table info)
    ;; Standard table.
    (let* ((caption (org-export-get-caption table))
	   (number (org-export-get-ordinal
		    table info nil #'t--has-caption-p))
	   (attributes
	    (t--make-attribute-string
	     (org-combine-plists
	      (list :id (t--reference table info t))
	      (and (not (t-html5-p info))
		   (plist-get info :html-table-attributes))
	      (org-export-read-attribute :attr_html table))))
	   (alignspec
	    (if (bound-and-true-p t-format-table-no-css)
		"align=\"%s\""
	      "class=\"org-%s\""))
	   (table-column-specs
	    (lambda (table info)
	      (mapconcat
	       (lambda (table-cell)
		 (let ((alignment (org-export-table-cell-alignment
				   table-cell info)))
		   (concat
		    ;; Begin a colgroup?
		    (when (org-export-table-cell-starts-colgroup-p
			   table-cell info)
		      "\n<colgroup>")
		    ;; Add a column.  Also specify its alignment.
		    (format "\n%s"
			    (t-close-tag
			     "col" (concat " " (format alignspec alignment)) info))
		    ;; End a colgroup?
		    (when (org-export-table-cell-ends-colgroup-p
			   table-cell info)
		      "\n</colgroup>"))))
	       (t-table-first-row-data-cells table info) "\n"))))
      (format "<table%s>\n%s\n%s\n%s</table>"
	      (if (equal attributes "") "" (concat " " attributes))
	      (if (not caption) ""
		(format (if (plist-get info :html-table-caption-above)
			    "<caption class=\"t-above\">%s</caption>"
			  "<caption class=\"t-bottom\">%s</caption>")
			(concat
			 "<span class=\"table-number\">"
			 (format (t--translate "Table %d:" info) number)
			 "</span> " (org-export-data caption info))))
	      (funcall table-column-specs table info)
	      contents))))

;;;; Target

(defun t-target (target _contents info)
  "Transcode a TARGET object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (let ((ref (t--reference target info)))
    (t--anchor ref nil nil info)))

;;;; Timestamp

(defun t-timestamp (timestamp _contents info)
  "Transcode a TIMESTAMP object from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (let ((value (t-plain-text (org-timestamp-translate timestamp) info)))
    (format "<span class=\"timestamp-wrapper\"><span class=\"timestamp\">%s</span></span>"
	    (replace-regexp-in-string "--" "&#x2013;" value))))

;;;; Underline

(defun t-underline (_underline contents info)
  "Transcode UNDERLINE from Org to HTML.
CONTENTS is the text with underline markup.  INFO is a plist
holding contextual information."
  (format (or (cdr (assq 'underline (plist-get info :html-text-markup-alist)))
	      "%s")
	  contents))

;;;; Verbatim

(defun t-verbatim (verbatim _contents info)
  "Transcode VERBATIM from Org to HTML.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (format (or (cdr (assq 'verbatim (plist-get info :html-text-markup-alist))) "%s")
	  (t-encode-plain-text (org-element-property :value verbatim))))

;;;; Verse Block

(defun t-verse-block (_verse-block contents info)
  "Transcode a VERSE-BLOCK element from Org to HTML.
CONTENTS is verse block contents.  INFO is a plist holding
contextual information."
  (format "<p class=\"verse\">\n%s</p>"
	  ;; Replace leading white spaces with non-breaking spaces.
	  (replace-regexp-in-string
	   "^[ \t]+" (lambda (m) (t--make-string (length m) "&#xa0;"))
	   ;; Replace each newline character with line break.  Also
	   ;; remove any trailing "br" close-tag so as to avoid
	   ;; duplicates.
	   (let* ((br (t-close-tag "br" nil info))
		  (re (format "\\(?:%s\\)?[ \t]*\n" (regexp-quote br))))
	     (replace-regexp-in-string re (concat br "\n") contents)))))


;;; Filter Functions

(defun t-final-function (contents _backend info)
  "Filter to indent the HTML and convert HTML entities."
  (with-temp-buffer
    (insert contents)
    (set-auto-mode t)
    (when (plist-get info :html-indent)
      (indent-region (point-min) (point-max)))
    (buffer-substring-no-properties (point-min) (point-max))))


;;; End-user functions

;;;###autoload
(defun t-export-as-html
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to an HTML buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org HTML Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-export-to-buffer 'yyhtml "*Org HTML Export*"
    async subtreep visible-only body-only ext-plist
    (lambda () (set-auto-mode t))))

;;;###autoload
(defun t-convert-region-to-html ()
  "Assume the current region has Org syntax, and convert it to HTML.
This can be used in any buffer.  For example, you can write an
itemized list in Org syntax in an HTML buffer and use this command
to convert it."
  (interactive)
  (org-export-replace-region-by 'yyhtml))

;;;###autoload
(defun t-export-to-html
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a HTML file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Return output file's name."
  (interactive)
  (let* ((extension (concat
		     (when (> (length t-extension) 0) ".")
		     (or (plist-get ext-plist :html-extension)
			 t-extension
			 "html")))
	 (file (org-export-output-file-name extension subtreep))
	 (org-export-coding-system t-coding-system))
    (org-export-to-file 'yyhtml file
      async subtreep visible-only body-only ext-plist)))

;;;###autoload
(defun t-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'yyhtml filename
		      (concat (when (> (length t-extension) 0) ".")
			      (or (plist-get plist :html-extension)
				  t-extension
				  "html"))
		      plist pub-dir))


(provide 'ox-yyhtml)

;; Local variables:
;; read-symbol-shorthands: (("t-" . "org-yyhtml-"))
;; End:

;;; ox-yyhtml.el ends here
