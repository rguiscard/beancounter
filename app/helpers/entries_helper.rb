module EntriesHelper
  def linkable_entry(entry)
    x = []
    x << link_to(entry.date.strftime("%Y-%m-%d"), entries_path(q: {date: entry.date.strftime("%Y-%m-%d")}, redirect: true))
    if entry.asterisk?
      x << "*"
    elsif entry.exclamation?
      x << "!"
    else
      x << entry.directive
    end

    arguments = entry.arguments
    entry.tags.each do |tag|
      arguments = arguments.gsub("#"+tag, "")
    end
    entry.links.each do |link|
      arguments = arguments.gsub("^"+link, "")
    end
    x << arguments.strip

    entry.tags.each do |tag|
      x << link_to("#"+tag, entries_path(q: {tag: tag}, redirect: true))
    end

    entry.links.each do |link|
      x << link_to("^"+link, entries_path(q: {link: link}, redirect: true))
    end

    x.join(" ").html_safe
  end
end
