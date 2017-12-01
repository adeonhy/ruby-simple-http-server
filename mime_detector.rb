module SimpleServer
  class MimeDetector
    DEFINITION_FILE = 'mime.types'

    def initialize
      @mime_types = {}
      load_file
    end

    def load_file
      source = File.read(DEFINITION_FILE)
      source.each_line do |line|
        type, *exts = line.split(/\s+/).reject(&:empty?)

        next if type == 'types'
        next unless type
        next if type.chars.first == '#'
        next if exts.empty?

        exts.each do |ext|
          semicolon_trimmed = ext.sub(/\;$/, '')
          set_mime(semicolon_trimmed, type)
        end
      end
    end

    def get_mime(ext)
      @mime_types[ext]
    end

    def set_mime(ext, type)
      @mime_types[ext] = type
    end
  end
end
