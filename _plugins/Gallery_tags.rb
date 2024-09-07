module Gallery_tags
  class CategoryPageGenerator < Jekyll::Generator
    safe false

    def generate(site)
      for tag in site.data["image_tags"]  # Creates a new gallery page for each tag
        site.pages << CategoryPage.new(site, tag)
      end
    end
  end

  # Subclass of `Jekyll::Page` with custom method definitions.
  class CategoryPage < Jekyll::Page
    def initialize(site, tag)
      @site = site             # the current site instance.
      @base = site.source      # path to the source directory.
      @dir  = "gallery"        # the directory the page will reside in.

      # All pages have the same filename, so define attributes straight away.
      @basename = tag["name"].sub(' ', '_')   # filename without the extension.
      @ext      = '.html'             # the extension.
      @name     = basename+'.html'         # basically @basename + @ext.

      # Initialize data hash with a key pointing to all posts under current category.
      # This allows accessing the list in a template via `page.linked_docs`.
      @data = {'allowed-tag' => tag["id"]}

      # Look up front matter defaults scoped to type `gallery-tags`, if given key
      # doesn't exist in the `data` hash.
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(relative_path, :gallery_tags, key)
      end
    end

    # Placeholders that are used in constructing page URL.
    def url_placeholders
      {
        :path       => @dir,
        :category   => @dir,
        :basename   => basename,
        :output_ext => output_ext,
      }
    end
  end
end