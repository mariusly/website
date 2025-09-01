;;; Copyright (C) 2025 Marius <mail@marius.pm>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(use-modules (haunt asset)
			 (haunt utils)
			 (haunt site)
			 (haunt post)
			 (haunt html)
			 (haunt page)
			 (haunt builder blog)
			 (haunt builder atom)
			 (haunt builder rss)
			 (haunt builder assets)
			 (haunt builder flat-pages)
			 (haunt reader commonmark)
			 (srfi srfi-19)
			 (ice-9 match)
			 (web uri))

;; First paragraph extractor from David Thompson
;; https://git.dthompson.us/blog/tree/theme.scm
(define (first-paragraph post)
  (let loop ((sxml (post-sxml post)))
    (match sxml
      (() '())
      (((and paragraph ('p . _)) . _)
       (list paragraph))
      ((head . tail)
       (cons head (loop tail))))))

(define my-theme
  (theme #:name "my-theme"
         #:layout
         (lambda (site title body)
           `((doctype "html")
             (html (@ (lang "en"))
                   (head
                    (meta (@ (charset "UTF-8")))
                    (meta (@ (name "viewport") (content "width=device-width, initial-scale=1.0")))
                    (title ,(string-append title " — " (site-title site)))
                    (link (@
						   (rel "stylesheet")
						   (href "https://cdnjs.cloudflare.com/ajax/libs/modern-normalize/3.0.1/modern-normalize.min.css")))
                    (link (@
						   (rel "stylesheet")
						   (href "/css/style.css")))
                    (link (@
						   (rel "stylesheet")
						   (href
							"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/nnfx-dark.min.css")
						   (media "(prefers-color-scheme: dark)")))
                    (link (@
						   (rel "stylesheet")
						   (href
							"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/nnfx-light.min.css")
						   (media "(prefers-color-scheme: light)")))
                    (script (@
							 (src "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js")))
                    (script (@
							 (src "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/scheme.min.js")))
                    (link (@
						   (rel "icon")
						   (type "image/png")
						   (href "/images/icon-192.png")
						   (sizes "192x192"))))
                   (body
                    (div (@ (class "wrapper"))
                         (header
                          (h1 (span (@ (class "lambda")) "λ") " " ,(site-title site))
                          (ul
                           (li (a (@ (href "/index.html")) "Home"))
                           (li (a (@ (href "/about.html")) "About"))
                           (li (a (@ (href "https://git.marius.pm")) "Git ⤴"))
                           (li (a (@ (href "https://github.com/mariusly")) "GitHub ⤴"))
                           (li (a (@ (href "https://codeberg.org/mariusly")) "Codeberg ⤴"))))
                         (hr)
                         (main ,body)
                         (hr)
                         (footer
                          (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0/") (class "cc"))
                             (img (@ (src "/images/cc.png") (alt "CC-BY-NC-SA-4.0"))))
                          (p "© 2025 marius.pm, Ramblings "
                             (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0/")) "CC-BY-NC-SA-4.0")
                             ", " (a (@ (href "#")) "Source") " "
                             (a (@ (href "https://www.gnu.org/licenses/gpl-3.0.txt")) "GPL-3.0") ".")
                          (p "This website is built with "
                             (a (@ (href "https://dthompson.us/projects/haunt.html")) "Haunt")
                             ", a static site generator written in "
                             (a (@ (href "https://gnu.org/software/guile")) "Guile Scheme") ".")
                          (p (a (@ (href "feed.xml")) "feed.xml")))
                         (script "hljs.highlightAll();"))))))

         #:post-template
         (lambda (post)
           `((article (@ (class "post"))
					  (div (@ (class "date"))
						   ,(date->string (post-date post)
										  "~B ~d, ~Y"))

					  (h2 (@ (class "title")),(post-ref post 'title))

					  (ul (@ (class "tags")) ,@(map (lambda (tag)
													  `(li (@ (class "tag"))
														   (a (@ (href ,(string-append "/feeds/tags/"
																					   tag ".xml")))
															  ,(string-append "#" tag))))
													(assq-ref (post-metadata post) 'tags)))
					  (div (@ (class "post"))
						   ,(post-sxml post)))))

         #:collection-template
         (lambda (site title posts prefix)
           (define (post-uri post)
             (string-append prefix "/" (site-post-slug site post) ".html"))

           `(,(map (lambda (post)
					 (let ((uri (post-uri post)))
                       `(div (@ (class "post"))
							 (span (@ (class "date"))
								   ,(date->string (post-date post)
												  "~B ~d, ~Y"))

							 (h2 (a (@ (href ,uri))
									,(post-ref post 'title)))

							 (p ,(first-paragraph post))

							 (div (@ (class "tags-container"))


								  (ul (@ (class "tags")) ,@(map (lambda (tag)
																  `(li (@
																		(class "tag"))
																	   (a (@ (href ,(string-append "/feeds/tags/"
																								   tag ".xml")))
																		  ,(string-append "#" tag))))
																(assq-ref (post-metadata post) 'tags)))

								  (a (@ (href ,uri) (class "read-more"))
									 , "Read More ›")))))
				   posts)))

         #:pagination-template
         (lambda (site body previous-page next-page)
           `(,@body
             (div
              ,(if previous-page
                   `(a (@ (href ,previous-page))
                       "Newer Posts ›")
                   '())
              ,(if next-page
                   `(a (@ (href ,next-page))
                       "‹ Older Posts")
                   '()))))))

(define post-prefix "/posts")

(define collections
  `(("Recent Posts" "index.html" ,posts/reverse-chronological)))

(site #:title "marius.pm"
      #:domain "marius.pm"
      #:default-metadata
      '((author . "marius")
        (email  . "mail@marius.pm"))
      #:readers (list commonmark-reader)
      #:builders (list (blog #:theme my-theme
							 #:collections collections
							 #:post-prefix post-prefix
							 #:posts-per-page 10)
					   (flat-pages "pages"
								   #:template (theme-layout my-theme))

					   (atom-feed #:blog-prefix post-prefix)
					   (atom-feeds-by-tag #:blog-prefix post-prefix)

					   (static-directory "images")
					   (static-directory "css")))
