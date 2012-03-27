require 'test_helper'

class DegreesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:degrees)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_degree
    assert_difference('Degree.count') do
      post :create, :degree => { }
    end

    assert_redirected_to degree_path(assigns(:degree))
  end

  def test_should_show_degree
    get :show, :id => degrees(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => degrees(:one).id
    assert_response :success
  end

  def test_should_update_degree
    put :update, :id => degrees(:one).id, :degree => { }
    assert_redirected_to degree_path(assigns(:degree))
  end

  def test_should_destroy_degree
    assert_difference('Degree.count', -1) do
      delete :destroy, :id => degrees(:one).id
    end

    assert_redirected_to degrees_path
  end
end
