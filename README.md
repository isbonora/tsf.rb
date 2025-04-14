# TSF.rb
Ruby parser for Trotect's TSF file format. The TSF file format is the main format of [Trotec's JobControl software](https://www.troteclaser.com/de/lasermaschinen/jobcontrol). JobControl is the key piece of software between a design in illustrator and a trotec laser machine. To create a TSF, you _print_ from design software to JobControl to generate a TSF with vector lines and bitmaps for cutting and engraving. Typically these files are only previewable by JobControl, making it difficult to share & reuse files within an organisation with confidence.

This Ruby Gem is used as an interface with the TSF file format to read metadata, bitmap, and polygon data, as well as generate previews of the files without the need for JobControl or design software. 

# Get started
## Instalation

```bash
bundle install tsf
```

## How to use

```ruby
require 'tsf'

data = File.read('to/your/file.tsf')
vector = TSF::Vector.load_tsf(data)

vector.loaded
# => True
```