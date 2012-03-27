require File.dirname(__FILE__) + '/../test_helper'

class UserFlowsTest < ActionController::IntegrationTest
  fixtures :all

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def setup
    https!
  
    @bob_info = { :first_name => 'Bob', :last_name => 'Smith', :pre_title, 'Mr.',
                 :email => 'bob@sageserver.com', :plain_password => 'p1234', :degree1 => 'MD',
                 :employer => 'UNC Hospital', :position_title => 'Dept. Head', :address_1 => '231 Flemington Rd.',
                 :city => 'Chapel Hill', :state_province_id => '10', :country_id => '20',
                 :phone_preferred => '919-338-2748', :phone_fax => '919-433-0000', :url => 'http://sageserver.com' }
  end
  
  
  def test_signup
    # signup
    get "/signup"
    assert_response :success
    
    bob = users(:bob)
    
    post_via_redirect "/signup", :user => {:first_name => bob.first_name, :last_name => bob.last_name}
    assert_response :error
  end
  
  
  def test_login_and_browse_site
    # login
    get "/login"
    assert_response :success
    
    post_via_redirect "/login", :username => User.find(120).password 
  end
  
  private
  
  def login(user)
    open_session do |sess|
      sess.extend(CustomDsl)
      u = users(user)
      sess.https!
      sess.post "/login", :username => u.username,
                          :password => u.password
      assert_equal '/welcome', path 
      sess.https!(false)
    end
  end 
end
