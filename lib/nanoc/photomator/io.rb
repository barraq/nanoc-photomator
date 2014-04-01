module Nanoc
  module Photomator
    module IO
      def meta_from(file_name)
        if File.exist? file_name
          YAML.load_file(file_name)
        else
          {}
        end
      end

      def save_meta_at(file_name, meta)
        unless meta == {}
          File.open(file_name, 'w') do |io|
            io.write(meta_as_string(meta))
          end
        end
      end

      def meta_as_string(meta)
        YAML.dump(meta.stringify_keys_recursively).strip.gsub(%r{\A---\n}, '')
      end

      def all_photos_and_metafile_at(dir_name)
        Dir.entries(dir_name).
            select { |fn| fn =~ /(\.jpg|\.png|\.tiff)$/ }.
            collect do |fn|
          [File.join(dir_name, File.basename(fn, '.*') + '.yaml'), File.join(dir_name, fn)]
        end
      end
    end
  end
end