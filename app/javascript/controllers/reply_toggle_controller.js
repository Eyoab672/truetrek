import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    commentId: Number,
    mention: String
  }

  showForm() {
    const commentId = this.commentIdValue
    const mention = this.mentionValue
    const placeholder = document.getElementById(`reply_form_placeholder_${commentId}`)

    if (!placeholder) return

    // Check if form already exists
    const existingForm = document.getElementById(`reply_form_${commentId}`)
    if (existingForm) {
      const input = existingForm.querySelector('.reply-input')
      if (input) {
        if (mention) {
          // Replying to a reply - add @mention
          // Extract any existing text without previous mentions
          const existingText = input.value.replace(/^@\w+\s*/, '').trim()
          input.value = `@${mention} ${existingText}`
          input.placeholder = `Replying to @${mention}...`
        } else {
          // Replying to original comment - remove any @mention
          const existingText = input.value.replace(/^@\w+\s*/, '').trim()
          input.value = existingText
          input.placeholder = 'Write a reply...'
        }
        const length = input.value.length
        input.focus()
        input.setSelectionRange(length, length)
      }
      return
    }

    // Create and insert the form via Turbo Frame
    const formHtml = this.buildFormHtml(commentId, mention)
    placeholder.innerHTML = formHtml

    // Focus on the input and set cursor position after mention
    const input = placeholder.querySelector('.reply-input')
    if (input) {
      if (mention) {
        input.value = `@${mention} `
        // Place cursor at the end after the mention
        const length = input.value.length
        input.focus()
        input.setSelectionRange(length, length)
      } else {
        input.focus()
      }
    }

    // Expand replies if collapsed
    const wrapper = document.getElementById(`replies_wrapper_${commentId}`)
    if (wrapper && wrapper.dataset.expanded === "false") {
      wrapper.dataset.expanded = "true"
      wrapper.classList.add('expanded')
    }
  }

  buildFormHtml(commentId, mention) {
    const placeholder = mention ? `Replying to @${mention}...` : 'Write a reply...'
    return `
      <turbo-frame id="reply_form_${commentId}">
        <div class="reply-form-container" data-controller="reply-form mention-autocomplete">
          <form action="/comments/${commentId}/replies" method="post" accept-charset="UTF-8" class="reply-form" data-turbo="true">
            <input type="hidden" name="authenticity_token" value="${document.querySelector('meta[name="csrf-token"]').content}">
            <div class="reply-input-wrapper">
              <input type="text" name="comment[description]" placeholder="${placeholder}" class="reply-input" data-reply-form-target="input" data-mention-autocomplete-target="input">
              <div class="reply-form-actions">
                <button type="submit" class="reply-submit-btn">Reply</button>
                <button type="button" class="reply-cancel-btn" data-action="click->reply-form#cancel">Cancel</button>
              </div>
            </div>
          </form>
        </div>
      </turbo-frame>
    `
  }
}
