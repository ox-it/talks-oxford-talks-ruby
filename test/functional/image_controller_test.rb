require File.dirname(__FILE__) + '/../test_helper'
require 'image_controller'

# Re-raise errors caught by the controller.
class ImageController; def rescue_action(e) raise e end; end

class ImageControllerTest < ActionController::TestCase
  def setup
    @controller = ImageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    File.open(File.dirname(__FILE__) + '/../../public/images/az.gif','r') do |image_file|
      image_file.extend FileCGICompatability
      @image = Image.create :data => image_file
    end
  end
  
  def test_routing
    #assert_routing '/image/show/1/image.png/200x200', {:controller => 'image', :action => 'show', :id => '1', :geometry => '200x200'}

    with_options :controller => 'image', :id => '1', :action => 'show' do |test|
      test.assert_routing '/image/show/1/image.png/200x200', :geometry => '200x200'
    end
  end
  
  def test_show
    get :show, :id => @image.id
    assert_response :success
    assert_equal "image/png", @response.headers["Content-Type"]
    assert_equal 'public', @response.headers['Cache-Control']
    # XXX Testing response.body.size is a bit flaky, it varies with installed image library version?
    # Hack to different size
    assert_equal 393, @response.body.size
  end
  
  def test_show_smaller
    get :show, :id => @image.id, :geometry => '10x10'
      assert_response :success
    # XXX Testing response.body.size is a bit flaky, it varies with installed image library version?
    assert_equal 384, @response.body.size
  end
  
end
