require 'test_helper'

class ManuscriptTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manuscript_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manuscript_type" do
    assert_difference('ManuscriptType.count') do
      post :create, :manuscript_type => { }
    end

    assert_redirected_to manuscript_type_path(assigns(:manuscript_type))
  end

  test "should show manuscript_type" do
    get :show, :id => manuscript_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => manuscript_types(:one).id
    assert_response :success
  end

  test "should update manuscript_type" do
    put :update, :id => manuscript_types(:one).id, :manuscript_type => { }
    assert_redirected_to manuscript_type_path(assigns(:manuscript_type))
  end

  test "should destroy manuscript_type" do
    assert_difference('ManuscriptType.count', -1) do
      delete :destroy, :id => manuscript_types(:one).id
    end

    assert_redirected_to manuscript_types_path
  end
end
