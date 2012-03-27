require 'test_helper'

class UserTemplatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:user_templates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user_template
    assert_difference('UserTemplate.count') do
      post :create, :user_template => { }
    end

    assert_redirected_to user_template_path(assigns(:user_template))
  end

  def test_should_show_user_template
    get :show, :id => user_templates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => user_templates(:one).id
    assert_response :success
  end

  def test_should_update_user_template
    put :update, :id => user_templates(:one).id, :user_template => { }
    assert_redirected_to user_template_path(assigns(:user_template))
  end

  def test_should_destroy_user_template
    assert_difference('UserTemplate.count', -1) do
      delete :destroy, :id => user_templates(:one).id
    end

    assert_redirected_to user_templates_path
  end
end
