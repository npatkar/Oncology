require 'test_helper'

class EmailsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:emails)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_email
    assert_difference('Email.count') do
      post :create, :email => { }
    end

    assert_redirected_to email_path(assigns(:email))
  end

  def test_should_show_email
    get :show, :id => emails(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => emails(:one).id
    assert_response :success
  end

  def test_should_update_email
    put :update, :id => emails(:one).id, :email => { }
    assert_redirected_to email_path(assigns(:email))
  end

  def test_should_destroy_email
    assert_difference('Email.count', -1) do
      delete :destroy, :id => emails(:one).id
    end

    assert_redirected_to emails_path
  end
end
