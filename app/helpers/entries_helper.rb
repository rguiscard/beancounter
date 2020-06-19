module EntriesHelper
  def linkable_entry(entry, **options)
    options = options.reverse_merge(only: [:date, :tag, :link], clickable_title: false)

    title = []
    x = []

    if options[:only].include?(:date)
      x << link_to(entry.date.strftime("%Y-%m-%d"), entries_path(q: {date: entry.date.strftime("%Y-%m-%d")}, redirect: true))
    else
      title << entry.date.strftime("%Y-%m-%d")
    end

    if entry.asterisk?
      title << "*"
    elsif entry.exclamation?
      title << "!"
    else
      title << entry.directive
    end

    arguments = entry.arguments

    if options[:only].include?(:tag)
      entry.tags.each do |tag|
        arguments = arguments.gsub("#"+tag, "")
      end
    end

    if options[:only].include?(:link)
      entry.links.each do |link|
        arguments = arguments.gsub("^"+link, "")
      end
    end

    title << arguments.strip

    if options[:clickable_title]
      x << link_to(title.join(" "), entry)
    else
      x << title
    end

    if options[:only].include?(:tag)
      entry.tags.each do |tag|
        x << link_to("#"+tag, entries_path(q: {tag: tag}, redirect: true))
      end
    end

    if options[:only].include?(:link)
      entry.links.each do |link|
        x << link_to("^"+link, entries_path(q: {link: link}, redirect: true))
      end
    end

    x.flatten.join(" ").html_safe
  end
end
