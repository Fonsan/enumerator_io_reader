require 'spec_helper'
class Enumerator
  module IO
    describe Reader do
      let(:io) { Reader.new(enum) }
      describe "when called with never yielding enumerator" do
        let(:enum) { [].to_enum }
        it 'reads empty string when doing full read' do
          expect(io.read).to eq("")
        end

        it 'reads nil when reading 10 bytes' do
          expect(io.read(10)).to be_nil
        end

        it 'reaches eof' do
          expect(io.eof?).to be true
        end
      end

      describe "when called with enumerator yielding once" do
        let(:enum) { ['one'].to_enum }

        it 'reads empty string when doing full read' do
          expect(io.read).to eq("one")
        end

        it 'reads "one" when reading 10 bytes' do
          expect(io.read(10)).to eq('one')
        end

        it 'reads the first byte when reading 1 byte' do
          expect(io.read(1)).to eq('o')
        end

        it 'reads the second byte when reading 1 byte the second time' do
          io.read(1)
          expect(io.read(1)).to eq('n')
        end

        it 'reads the rest of bytes when reading everything the second time' do
          io.read(1)
          expect(io.read).to eq('ne')
        end

        it 'has not reached eof before reading anything' do
          expect(io.eof?).to be false
        end

        it 'has not reached eof after reading one byte' do
          io.read(1)
          expect(io.eof?).to be false
        end

        it 'reaches eof after reading three bytes' do
          io.read(3)
          expect(io.eof?).to be true
        end

        it 'reaches eof after doing full read' do
          io.read
          expect(io.eof?).to be true
        end
      end

      describe "when called with enumerator yielding three times" do
        let(:enum) { ['o','n','e'].to_enum }

        it 'reads empty string when doing full read' do
          expect(io.read).to eq("one")
        end

        it 'reads "one" when reading 10 bytes' do
          expect(io.read(10)).to eq('one')
        end

        it 'reads the first byte when reading 1 byte' do
          expect(io.read(1)).to eq('o')
        end

        it 'reads the second byte when reading 1 byte the second time' do
          io.read(1)
          expect(io.read(1)).to eq('n')
        end

        it 'reads the rest of bytes when reading everything the second time' do
          io.read(1)
          expect(io.read).to eq('ne')
        end

        it 'has not reached eof before reading anything' do
          expect(io.eof?).to be false
        end

        it 'has not reached eof after reading one byte' do
          io.read(1)
          expect(io.eof?).to be false
        end

        it 'reaches eof after reading three bytes' do
          io.read(3)
          expect(io.eof?).to be true
        end

        it 'reaches eof after doing full read' do
          io.read
          expect(io.eof?).to be true
        end
      end

      describe "when created with block" do
        let(:io) { Reader.new(enum) {|e| e.to_s.reverse } }
        let(:enum) { (-2..3).to_enum }

        it 'maps yielded data' do
          expect(io.read).to eq("2-1-0123")
        end
      end
    end
  end
end