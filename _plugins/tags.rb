module Jekyll
  class TagPageGenerator < Generator
    safe true

    def generate(site)
      tags = site.posts.docs.flat_map { |post| post.data['tags'] || [] }.to_set
      tags.each do |tag|
        tag_slug = Jekyll::Utils.slugify(tag.to_s, mode: "pretty", cased: false)
        site.pages << TagPage.new(site, site.source, tag, tag_slug)
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, tag, tag_slug)
      @site = site
      @base = base
      @dir  = File.join('tags', tag_slug)
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['tag_slug'] = tag_slug
      self.data['title'] = "Tag: #{tag}"
    end
  end
end
