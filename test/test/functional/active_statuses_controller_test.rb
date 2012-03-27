require 'test_helper'

class ActiveStatusesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:active_statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_active_status
    assert_difference('ActiveStatus.count') do
      post :create, :active_status => { }
    end

    assert_redirected_to active_status_path(assigns(:active_status))
  end

  def test_should_show_active_status
    get :show, :id => active_statuses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => active_statuses(:one).id
    assert_response :success
  end

  def test_should_update_active_status
    put :update, :id => active_statuses(:one).id, :active_status => { }
    assert_redirected_to active_status_path(assigns(:active_status))
  end

  def test_should_destroy_active_status
    assert_difference('ActiveStatus.count', -1) do
      delete :destroy, :id => active_statuses(:one).id
    end

    assert_redirected_to active_statuses_path
  end
end
