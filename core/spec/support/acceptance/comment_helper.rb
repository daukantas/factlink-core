module Acceptance
  module CommentHelper
      def toggle_to_comment
        within add_evidence_form_css_selector do
          evidence_input = page.find_field 'text_input_view'
          evidence_input.click

          page.find('.js-switch').set true
        end
      end

      def toggle_to_factlink
        within add_evidence_form_css_selector do
          page.find('.js-switch').set false
        end
      end

      def posting_factlink?
        find('.fact-relation-search input[type=text]')[:placeholder]
          .include? 'Factlink'
      end

      def posting_comment?
        find('.fact-relation-search input[type=text]')[:placeholder]
          .include? 'Comment'
      end

      def add_comment comment
        toggle_to_comment if posting_factlink? #unless posting_comment?

        within add_evidence_form_css_selector do
          comment_input = page.find_field 'add_comment'

          comment_input.click
          #ensure button is enabled, i.e. doesn't say "posting":
          find('button', 'Post Comment')
          comment_input.set comment
          comment_input.value.should eq comment
          click_post_comment
        end
      end

      def add_existing_factlink evidence_factlink
        toggle_to_factlink unless posting_factlink?

        within add_evidence_form_css_selector do
          text = evidence_factlink.to_s
          page.find("input[type=text]").click
          page.find("input[type=text]").set(text)
          page.find("li", text: text).click
          # We assume a request immediately fires, and button reads "Posting..."

          # This *should* hold:
          page.find("button", text: "Posting...")
          # ...but the posting delay vs. capybara check is a race-condition
          # if this randomly fails, disable the above check.

          page.find("button", text: "Post Factlink")
        end
      end

      def add_new_factlink text
        toggle_to_factlink unless posting_factlink?

        within add_evidence_form_css_selector do
          page.find("input[type=text]").set(text)
          page.find("button", text: "Post Factlink").click
          # We assume a request immediately fires, and button reads "Posting..."

          # This *should* hold:
          page.find("button", text: "Posting...")
          # ...but the posting delay vs. capybara check is a race-condition
          # if this randomly fails, disable the above check.

          page.find("button", text: "Post Factlink")
        end
      end

      def add_sub_comment(comment)
        fill_in 'text_area_view', with: comment
        sleep 0.5 # To allow for the getting bigger CSS animation
        find('.evidence-sub-comments-button', text: 'Comment').click
        sleep 0.5 # To allow for the getting smaller CSS animation
      end

      def click_post_comment
        page.find("button", text: "Post comment").click
        # We assume a request immediately fires, and button reads "Posting..."
        page.find("button", text: "Post comment")
      end

      def assert_sub_comment_exists(comment)
        find('.evidence-sub-comment-content', text: comment)
      end

      def add_evidence_form_css_selector
        '.fact-relation-search'
      end

      def js_displaystring_css_selector
        ".js-displaystring"
      end

      def evidence_item_css_selector
        '.evidence-item'
      end

      def evidence_listing_css_selector
        '.fact-relation-listing'
      end

      def js_content_css_selector
        '.js-content'
      end
  end
end
