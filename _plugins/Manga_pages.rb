module Manga_pages
  class MangaPageGenerator < Jekyll::Generator
    safe false

    def generate(site)

      # Creates a new page for each manga chapter
      if site.data["manga_dirs"].is_a? Enumerable
        for manga in site.data["manga_dirs"]
          site.pages << MangaPage.new(site, manga, manga["name"])
        end
      end
    end
  end

  # Subclass of `Jekyll::Page` with custom method definitions.
  class MangaPage < Jekyll::Page
    def getCategory(id)
      for category in site.data["manga_categories"]
        if category['id'] == id
          return category
        end
      end
    end

    def initialize(site, manga, chapter)
      @site = site             # the current site instance.
      @base = site.source      # path to the source directory.
      @dir  = "legacy"         # the directory the page will reside in.

      if manga["categories"].is_a? Enumerable
        for categoryID in manga["categories"]
          @dir += "/"+getCategory(categoryID)['name'].gsub(' ','_')
        end
      else
        @dir += "/"+getCategory(manga["categories"])['name'].gsub(' ','_')
      end

      # All pages have the same filename, so define attributes straight away.
      @basename = chapter.gsub(' ', '_')   # filename without the extension.
      @ext      = '.html'                 # the extension.
      @name     = basename+ext         

      # Initialize data hash with a key pointing to all posts under current category.
      # This allows accessing the list in a template via `page.linked_docs`.
      @data = {
        'allowed-manga' => manga["id"],
        'allowed-chapter' => chapter
      }

      # Look up front matter defaults scoped to type `gallery-tags`, if given key
      # doesn't exist in the `data` hash.
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(relative_path, :manga_pages, key)
      end
    end

    # Placeholders that are used in constructing page URL.
    def url_placeholders
      {
        :path       => @dir,
        :basename   => basename,
        :output_ext => output_ext,
      }
    end
  end
end