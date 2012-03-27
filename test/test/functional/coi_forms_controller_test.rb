require 'test_helper'

class CoiFormsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:coi_forms)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_coi_form
    assert_difference('CoiForm.count') do
      post :create, :coi_form => { }
    end

    assert_redirected_to coi_form_path(assigns(:coi_form))
  end

  def test_should_show_coi_form
    get :show, :id => coi_forms(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => coi_forms(:one).id
    assert_response :success
  end

  def test_should_update_coi_form
    put :update, :id => coi_forms(:one).id, :coi_form => { }
    assert_redirected_to coi_form_path(assigns(:coi_form))
  end

  def test_should_destroy_coi_form
    assert_difference('CoiForm.count', -1) do
      delete :destroy, :id => coi_forms(:one).id
    end

    assert_redirected_to coi_forms_path
  end
end
