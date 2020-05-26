require "application_system_test_case"

class PostingsTest < ApplicationSystemTestCase
  setup do
    @posting = postings(:one)
  end

  test "visiting the index" do
    visit postings_url
    assert_selector "h1", text: "Postings"
  end

  test "creating a Posting" do
    visit postings_url
    click_on "New Posting"

    fill_in "Account", with: @posting.account
    fill_in "Arguments", with: @posting.arguments
    fill_in "Comment", with: @posting.comment
    fill_in "Entry", with: @posting.entry_id
    fill_in "Flag", with: @posting.flag
    click_on "Create Posting"

    assert_text "Posting was successfully created"
    click_on "Back"
  end

  test "updating a Posting" do
    visit postings_url
    click_on "Edit", match: :first

    fill_in "Account", with: @posting.account
    fill_in "Arguments", with: @posting.arguments
    fill_in "Comment", with: @posting.comment
    fill_in "Entry", with: @posting.entry_id
    fill_in "Flag", with: @posting.flag
    click_on "Update Posting"

    assert_text "Posting was successfully updated"
    click_on "Back"
  end

  test "destroying a Posting" do
    visit postings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Posting was successfully destroyed"
  end
end
