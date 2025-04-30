% First identify the class:
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{openreader}

\LoadClass{article}

\RequirePackage[extrafootnotefeatures]{bidi}
\setfootnoteLR

\RequirePackage{etoolbox}

% Define custom options
\newif\ifgreek % the Biblical language is Greek
\newif\ifhebrew % the Biblical language is Hebrew (or Aramaic)
\newif\ifltr % the non-Biblical language is LTR
\newif\ifrtl % the non-Biblical language is RTL

\greekfalse
\hebrewfalse

\RequirePackage{polyglossia}
\def\textmainlanguage#1{\csname text\mainlanguagename\endcsname{#1}}
\def\selectmainlanguage{\selectlanguage{\mainlanguagename}}

\RequirePackage{titlesec}
% make sections (here, chapters) nice inline deals
\titleformat{\section}[runin]{\selectmainlanguage\bfseries}{}{}{}

\RequirePackage{fontspec}
\RequirePackage[a4paper,top=2cm,bottom=2cm,left=2cm,right=2cm]{geometry}


\RequirePackage{fancyhdr}
\fancypagestyle{plain}{
  \fancyhf{} % Clear all header and footer fields
  \fancyfoot[C]{\selectmainlanguage\thepage} % Footer with page number in the center
  \renewcommand{\headrulewidth}{0pt} % Remove header rule
  \renewcommand{\footrulewidth}{0pt} % Remove footer rule
}
\pagestyle{plain} % Apply the custom footer to all pages

\makeatletter
\renewcommand{\maketitle}{
  \begin{center}
    {\LARGE \@title \par}
  \end{center}
}
\makeatother

\def\FootnoteSubHeader#1{\textsuperscript{\selectmainlanguage #1}}
\def\FootnoteSubFooter{.\ }

\newcount\LastChapterNumber
\newcount\LastVerseNumber
\newif\ifThisIsTheFirstFootnoteForAVerse

% Print a verse marker in the main verse. The two arguments are chapter and verse
\def\MainTextVerseMark#1#2{%
  \global\LastChapterNumber=#1%
  \global\LastVerseNumber=#2%
  \global\ThisIsTheFirstFootnoteForAVersetrue%
  \ifnum#2=1
    % Don't print a verse marker, because there is already a chapter marker
  \else
    \textsuperscript{\selectmainlanguage\localnumeral{#2}\ }\,%
\fi}

% \def\VerseMarker#1{\textsuperscript{\selectmainlanguage #1}~}


% This is the footnote marker that goes over a word that is glossed or parsed.
\def\MainTextFootnoteMark#1{\textsuperscript{\selectmainlanguage #1}}

\def\Gloss#1{\textmainlanguage{\textit{#1}}}
\def\Parse#1{\textmainlanguage{#1}}

\let\Footnotesize=\footnotesize  % save the definition
\let\footnotesize=\large  % make a footnotesize change very visible

% this is the width of the hanging indent
\newdimen\FootnoteHangingIndent
\FootnoteHangingIndent=20pt

% maximum height of footnotes
\newdimen\FootnoteSectionHeight
\FootnoteSectionHeight=9in

\raggedbottom
\addtolength{\topskip}{0pt plus 10pt}

\def\VerseRef#1{\selectmainlanguage  #1\quad}

\newdimen\FootnoteTextSize
\newdimen\FootnoteBaselineSkip
\FootnoteTextSize=12pt
\FootnoteBaselineSkip=14pt

\ExplSyntaxOn
\NewExpandableDocumentCommand \langdir { m }
  {
    \prop_item:No \l_xpg_langsetup_prop { #1 / direction }
  }
\ExplSyntaxOff

\def\DefineLanguageDirection{%
\typeout{DefineLanguageDirection running.}
\typeout{\mainlanguagename}
\typeout{\langdir{\mainlanguagename}}
\typeout{\langdir{persian}}
}



% Macro that prints text either as Greek or Hebrew, depending on the "other" language.
\def\AsGreekOrHebrew#1{\ifgreek
\textgreek{#1}
\else
\ifhebrew
    \texthebrew{#1}
\fi
\fi}

% Equivalent of \footnotetext, but it checks the direction of the main language.
% The 10pt is the space alloted for the footnote marker, which I removed. This
% isn't great, but it's better than redefining all the bidi macros.
\def\MainLanguageFootnoteText#1{%
    \ifltr%
      \LTRfootnotetext{\hskip-10pt #1}%
    \else%
      \RTLfootnotetext{\hskip-10pt #1}%
    \fi%
}

% Creates a section header and puts a header in the footnotes as well.
\def\ChapterHeader#1#2{%
    \section*{#1}%
   \MainLanguageFootnoteText{\textmainlanguage{\textbf{#2}}}%
}

% Typeset the footnot marker as it should appear in the main text.
\def\FnMainTextMarker#1{\textsuperscript{\selectmainlanguage #1}}
% Typeset a footnote marker as it should appear in the footnote.
\def\FnFootnoteTextMarker#1{\hbox to 1em{\selectmainlanguage #1\hfil}}

% Typeset a verse marker in the footnote.
% If this is the first footnote of the verse, print the verse number.
% Otherwise print a space the width of the verse number (so that the 
% footnote markers will be vertically aligned).
\def\FnVerseMarker{%
    \setbox0=\hbox{\selectmainlanguage \localnumeral{\the\LastVerseNumber}\ }% Create a box with the verse number and a small space
    \ifThisIsTheFirstFootnoteForAVerse% if this is the first footnote for the verse
        \box0% print the box
        \global\ThisIsTheFirstFootnoteForAVersefalse% remember that it is no longer the first footnote for the verse
    \else%
        \hbox to \wd0{\hfil}% otherwise just print the space
    \fi%
}

\def\FnGenericTemplate#1#2{%
    \FnMainTextMarker{#1}%
    \MainLanguageFootnoteText{%
        % \noindent%
        \setbox0=\hbox{\FnVerseMarker\FnFootnoteTextMarker{#1}}% create the box with the verse marker and footnote marker
        \newdimen\contentwidth%
        \contentwidth=\hsize% get the width of the text area
        \advance\contentwidth by -\wd0% subtract the width of the box from the width of the text area       
        \box0% print the verse marker
        \vtop{%
            \hsize=\contentwidth% 
            \hbadness=10000 % Suppress overfull \hbox warnings
            \raggedright%
            \noindent#2%
        }%
    }%
}

\def\Form#1{\AsGreekOrHebrew{#1}}

% Typeset a footnote that only has a parsing
\def\FnParse#1#2{%
    \FnGenericTemplate{#1}{%
        \Parse{#2}% print the parsing
    }%
}
% Typeset a footnote that shows the lexical form and a gloss
\def\FnFormGloss#1#2#3{%
    \FnGenericTemplate{#1}{%
        \AsGreekOrHebrew{#2}% print the lexical form
        \Gloss{#3}% print the gloss
    }%
}

% Typeset a footnote that shows the parsing, lexical form, and a gloss
\def\FnParseFormGloss#1#2#3#4{%
    \FnGenericTemplate{#1}{%
        \Parse{#2}\ % print the parsing
        \AsGreekOrHebrew{#3}\ % print the lexical form
        \Gloss{#4}%
    }%
}

% Typeset the opening marker of a phrasal gloss (i.e., make the marker and typeset the footnote)
\def\FnPhrasalGlossOpening#1#2{%
  \FnGenericTemplate{#1}{%
    \Gloss{#2}%
  }%
}

\def\FnPhrasalGlossClosing#1{%
    \FnMainTextMarker{#1}%
}

% Awkward to do it this way, but calling selectlanguage seems to change \thefootnote
% Remove the footnote marker; we'll make our own (based on the TEI data).
\def\ORBselectlanguage#1{%
    \selectlanguage{#1}%
    \renewcommand\thefootnote{}%
    \raggededges%
}

% We need a little extra space between the main text and the footnote text.
\setlength{\skip\footins}{2em} 

% \paragraphfootnotes
\threecolumnfootnotes
% \fourcolumnfootnotes


% This will of course always be Hebrew.
\def\KetivMarker{\texthebrew{כת֗}}
\def\QereMarker{\texthebrew{ק֗}}
\def\KetivQere#1#2{\texthebrew{\KetivMarker\ #1 \QereMarker\ #2}\ }

\def\FnFreeform#1{\Gloss{#1}}


\AtBeginDocument{%

% Set the ifs for Greek and Hebrew
\iflanguageloaded{greek}{\greektrue}{\greekfalse}
\iflanguageloaded{hebrew}{\hebrewtrue}{\hebrewfalse}


\global\edef\MainLanguageDirection{\langdir{\mainlanguagename}}

% Check the value of \MainLanguageDirection and set \ifrtl accordingly
\def\RL{RL}
\ifx\MainLanguageDirection\RL
  \global\rtltrue
  \global\ltrfalse
  \typeout{RTL is true. LTR is false.}
\else
  \global\rtlfalse
  \global\ltrtrue
  \typeout{LTR is true. RTL is false.}
\fi

\typeout{Greek is \ifgreek true\else false\fi.}
\typeout{Hebrew is \ifhebrew true\else false\fi.}


% make the edges ragged
\def\raggededges{%
\ifgreek%
  \raggedright%
\fi%
\ifhebrew%
  \raggedleft%
\fi%
}


}

\def\FootnoteStyle#1{\typeout{TODO! Ignoring: #1}}

\endinput