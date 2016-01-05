# package commands

def lilypond_prefix(info)
  if info[:current] && info[:default]
    "=* "
  elsif info[:current]
    "=> "
  elsif info[:default]
    " * "
  else
    "   "
  end
end

def lilypond_postfix(info)
  if info[:system]
    " (system)"
  else
    ""
  end
end

def format_lilypond_entry(info)
  "#{lilypond_prefix(info)}#{info[:version]}#{lilypond_postfix(info)}"
end

LILYPOND_PREAMBLE = <<EOF

Lilypond versions:

EOF

LILYPOND_LEGEND = <<EOF

# => - current
# =* - current && default
#  * - default

EOF

command :list do |c|
  c.syntax =      "list [PATTERN]"
  c.description = "Lists installed versions of packages whose name matches PATTERN"
  c.action do |args, opts|
    pattern = args.first
    if pattern.nil? || pattern == 'lilypond'
      STDOUT.puts LILYPOND_PREAMBLE
      Lypack::Lilypond.list.each {|info| puts format_lilypond_entry(info)}
      STDOUT.puts LILYPOND_LEGEND
    else
      Lypack::Package.list(args.first).each {|p| puts p}
    end
  end
end



command :compile do |c|
  c.syntax = "compile <FILE>"
  c.description = "Resolves package dependencies and invokes lilypond"
  c.option '-c', '--config FILE', 'Set config file'
  c.action do |args, opts|
    begin
      raise "File not specified" if args.empty?
      Lypack::Lilypond.compile(ARGV[1..-1])
    rescue => e
      STDERR.puts e.message
      exit 1
    end
  end
end