class Enumerator
  module IO
      class Reader
      def initialize(enumerator, &block)
        @enumerator = enumerator
        @reader, @writer = ::IO.pipe
        @end_of_read_window = 0
        @read_bytes = 0
        @block = block
      end

      def read(*args)
        length = args.first
        if length
          required_read_window = @read_bytes + length 
          if required_read_window > @end_of_read_window
            increase_read_window!(required_read_window - @end_of_read_window)
          end
        else
          slurp!
        end
        result = @reader.read(*args)
        @read_bytes += result.size if result
        result
      end

      def eof?
        moar_data if @read_bytes == 0
        @reader.eof?
      end

      private

      def increase_read_window!(bytes_left)
        while bytes_left >= 0 && (written = moar_data) > 0
          bytes_left -= written
        end
      ensure
        @writer.flush unless @writer.closed?
      end

      def slurp!
        return if @writer.closed?
        while moar_data > 0
        end
      end

      def moar_data
        entry = @enumerator.next
        chunck = if @block
          @block.call(entry)
        else
          entry.to_s
        end
        @writer.write(chunck)
        @end_of_read_window += chunck.size
        chunck.size
      rescue StopIteration
        unless @writer.closed?
          @writer.flush
          @writer.close
        end
        0
      end
    end
  end
end