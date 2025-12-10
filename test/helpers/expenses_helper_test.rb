require "test_helper"

class ExpensesHelperTest < ActionView::TestCase
  # === category_emoji ===

  test "category_emoji returns correct emoji for electricity" do
    category = Category.new(name: "Électricité & Gaz")
    assert_equal "⚡", category_emoji(category)
  end

  test "category_emoji returns correct emoji for internet" do
    category = Category.new(name: "Box Internet")
    assert_equal "📡", category_emoji(category)
  end

  test "category_emoji returns correct emoji for habitation" do
    category = Category.new(name: "Assurance Habitation")
    assert_equal "🏠", category_emoji(category)
  end

  test "category_emoji returns correct emoji for auto" do
    category = Category.new(name: "Assurance Auto")
    assert_equal "🚗", category_emoji(category)
  end

  test "category_emoji returns correct emoji for moto" do
    category = Category.new(name: "Assurance Moto")
    assert_equal "🏍️", category_emoji(category)
  end

  test "category_emoji returns correct emoji for mutuelle" do
    category = Category.new(name: "Mutuelle Santé")
    assert_equal "🏥", category_emoji(category)
  end

  test "category_emoji returns correct emoji for banque" do
    category = Category.new(name: "Banque")
    assert_equal "🏦", category_emoji(category)
  end

  test "category_emoji returns pirate flag for arnaque" do
    category = Category.new(name: "Arnaque PDF")
    assert_equal "🏴‍☠️", category_emoji(category)
  end

  test "category_emoji returns default emoji for unknown category" do
    category = Category.new(name: "Something Random")
    assert_equal "📋", category_emoji(category)
  end

  test "category_emoji accepts string instead of category" do
    assert_equal "⚡", category_emoji("Électricité")
  end

  # === result_type_config ===

  test "result_type_config returns danger config" do
    config = result_type_config(:danger)
    assert_equal "🚨", config[:emoji]
    assert_equal "Alertes", config[:label]
    assert_equal "danger", config[:color]
  end

  test "result_type_config returns opportunity config" do
    config = result_type_config(:opportunity)
    assert_equal "💡", config[:emoji]
    assert_equal "Opportunités", config[:label]
    assert_equal "primary", config[:color]
  end

  test "result_type_config returns success config" do
    config = result_type_config(:success)
    assert_equal "⚖️", config[:emoji]
    assert_equal "Optimisé", config[:label]
    assert_equal "success", config[:color]
  end

  test "result_type_config returns default config for nil" do
    config = result_type_config(nil)
    assert_equal "💳", config[:emoji]
    assert_equal "Autres", config[:label]
    assert_equal "secondary", config[:color]
  end
end
