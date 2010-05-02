#!/usr/bin/env ruby
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010 - R.W. van 't Veer

require 'test_helper'

class JPEGTest < Test::Unit::TestCase
  def test_initialize
    all_test_jpegs.each do |fname|
      assert_nothing_raised do
        JPEG.new(fname)
      end
      assert_nothing_raised do
        open(fname) { |rd| JPEG.new(rd) }
      end
      assert_nothing_raised do
        JPEG.new(StringIO.new(File.read(fname)))
      end
    end
  end

  def test_size
    j = JPEG.new(f('image.jpg'))
    assert_equal j.width, 100
    assert_equal j.height, 75

    j = JPEG.new(f('exif.jpg'))
    assert_equal j.width, 100
    assert_equal j.height, 75

    j = JPEG.new(f('1x1.jpg'))
    assert_equal j.width, 1
    assert_equal j.height, 1
  end

  def test_comment
    assert_equal JPEG.new(f('image.jpg')).comment, "Here's a comment!"
  end

  def test_exif
    assert ! JPEG.new(f('image.jpg')).exif?
    assert JPEG.new(f('exif.jpg')).exif?
    assert_not_nil JPEG.new(f('exif.jpg')).exif.date_time
    assert_not_nil JPEG.new(f('exif.jpg')).exif.f_number
  end

  def test_to_hash
    h = JPEG.new(f('image.jpg')).to_hash
    assert_equal 100, h[:width]
    assert_equal 75, h[:height]
    assert_equal "Here's a comment!", h[:comment]

    h = JPEG.new(f('exif.jpg')).to_hash
    assert_equal 100, h[:width]
    assert_equal 75, h[:height]
    assert_kind_of Time, h[:date_time]
  end

  def test_exif_dispatch
    j = JPEG.new(f('exif.jpg'))

    assert JPEG.instance_methods.include?('date_time')
    assert j.methods.include?('date_time')
    assert j.respond_to?(:date_time)
    assert j.respond_to?('date_time')
    assert_not_nil j.date_time
    assert_kind_of Time, j.date_time
    assert_not_nil j.f_number
    assert_kind_of Rational, j.f_number
  end
  
  def test_geolocation
    j = JPEG.new(f('iPhone-gps.jpg'))
    assert j.methods.include?('gps_latitude')    
    assert j.gps_latitude[0].to_f ==37.0
    assert j.gps_latitude[1].to_f ==46.0
    assert j.gps_latitude[2].to_f ==43.024

    assert j.methods.include?('gps_longitude')
    assert j.gps_longitude[0].to_f ==122.0
    assert j.gps_longitude[1].to_f ==26.0
    assert j.gps_longitude[2].to_f ==20.211
    
    assert j.methods.include?('gps_lat')
    assert j.methods.include?('gps_lng')
    assert j.gps_lat.to_s == '37.7786177777778'
    assert j.gps_lng.to_s == '122.4389475'
     
    assert j.methods.include?('gps')
    gps=j.gps
    assert j.gps[0].to_s == '37.7786177777778'
    assert j.gps[1].to_s == '122.4389475'
    
  end

  def test_no_method_error
    assert_nothing_raised { JPEG.new(f('image.jpg')).f_number }
    assert_raise(NoMethodError) { JPEG.new(f('image.jpg')).foo }
  end

  def test_multiple_app1
    assert JPEG.new(f('multiple-app1.jpg')).exif?
  end

  def test_thumbnail
    count = 0
    all_test_jpegs.each do |fname|
      jpeg = JPEG.new(fname)
      unless jpeg.thumbnail.nil?
        assert_nothing_raised 'thumbnail not a JPEG' do
          JPEG.new(StringIO.new(jpeg.thumbnail))
        end
        count += 1
      end
    end

    assert count > 0, 'no thumbnails found'
  end
end
