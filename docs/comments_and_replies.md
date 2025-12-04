# Comments & Replies System

This document explains how the comments and replies feature works in TrueTrek.

## Overview

Users can leave comments on places they've visited, and other users can reply to those comments. It's like a conversation thread - similar to how comments work on Instagram or YouTube.

---

## How It Works

### 1. Comments

When you visit a place page (like "Eiffel Tower"), you'll see:
- A list of comments from other travelers
- A form to add your own comment (with photos)

**Key points:**
- Only logged-in users can comment
- Comments require at least 20 characters
- You can attach multiple photos
- You can only delete your own comments

### 2. Replies (Nested Comments)

Under each comment, users can:
- Click "Reply" to respond to that comment
- See existing replies by clicking "See X replies"
- Reply to other replies (the conversation continues)

**How replies are stored:**
- A reply is just a comment with a `parent_id`
- If `parent_id` is empty → it's a top-level comment
- If `parent_id` has a value → it's a reply to that comment

```
Comment (parent_id: nil)        ← Top-level comment
  └── Reply (parent_id: 1)      ← Reply to comment #1
  └── Reply (parent_id: 1)      ← Another reply to comment #1
```

### 3. @Mentions

You can mention any user by typing `@` followed by their username:

1. Type `@` in the reply box
2. A dropdown appears with matching users
3. Select a user or keep typing to filter
4. Press Enter/Tab or click to insert the mention

**Example:** `@john_doe check out this place!`

This lets you tag someone who isn't even in the conversation to come see it.

---

## No Page Refresh (Turbo)

The entire system works without refreshing the page:

- **Posting a reply** → appears instantly in the thread
- **Deleting a comment** → disappears immediately
- **Expanding replies** → smooth animation, no reload

This is powered by **Hotwire Turbo**, which updates only the parts of the page that changed.

---

## Files Involved

### Database
- `comments` table has a `parent_id` column that references itself
- If `parent_id` is NULL → top-level comment
- If `parent_id` is set → it's a reply

### Models
**`app/models/comment.rb`**
```ruby
belongs_to :parent, class_name: "Comment", optional: true
has_many :replies, class_name: "Comment", foreign_key: :parent_id
```
- A comment can have one parent (the comment it's replying to)
- A comment can have many replies

### Controllers
**`app/controllers/comments_controller.rb`**
- `create` - Post a new top-level comment
- `destroy` - Delete your own comment

**`app/controllers/replies_controller.rb`**
- `create` - Post a reply to a comment
- Returns a Turbo Stream to update the page without refresh

### Views
**`app/views/places/show.html.erb`**
- Shows all top-level comments (where `parent_id` is nil)
- Each comment has Reply/Delete buttons
- Includes the replies toggle and list

**`app/views/replies/`**
- `_reply.html.erb` - Single reply with avatar, username, text
- `_replies_list.html.erb` - Container for all replies
- `_toggle.html.erb` - "See X replies" button
- `_form.html.erb` - The reply input form
- `create.turbo_stream.erb` - Updates page after posting reply

### JavaScript (Stimulus Controllers)
**`app/javascript/controllers/`**

| Controller | What it does |
|------------|--------------|
| `reply_toggle_controller.js` | Shows the reply form when you click "Reply" |
| `reply_form_controller.js` | Handles cancel button on reply form |
| `replies_expand_controller.js` | Expands/collapses the replies thread |
| `mention_autocomplete_controller.js` | Shows @mention dropdown as you type |

### Styles
**`app/assets/stylesheets/components/_replies.scss`**
- Styling for replies, avatars, forms, mentions dropdown
- Animations for expand/collapse
- Mobile responsive adjustments

---

## User Journey Examples

### Posting a Reply
1. User sees a comment and clicks "Reply"
2. A text input appears below the comment
3. User types their reply (can @mention others)
4. User clicks "Reply" button
5. The reply appears instantly in the thread (no page refresh)

### Replying to a Reply
1. User expands replies by clicking "See X replies"
2. User clicks "Reply" on a specific reply
3. The input is pre-filled with `@username` of that person
4. User can keep the mention or delete it
5. Reply is posted to the same thread

### Mentioning Someone New
1. User is writing a reply
2. User types `@` to mention someone
3. Dropdown shows matching usernames
4. User selects someone (even if they're not in the thread)
5. That person's username is inserted

### Deleting a Comment
1. User sees their own comment (has "Delete" button)
2. User clicks "Delete"
3. Confirmation dialog: "Are you sure?"
4. Comment disappears (along with all its replies)

---

## Authorization (Who Can Do What)

| Action | Who can do it |
|--------|---------------|
| View comments | Everyone |
| Post a comment | Logged-in users |
| Reply to a comment | Logged-in users |
| Delete a comment | Only the comment author |
| @mention users | Logged-in users |

This is enforced by **Pundit** policies in `app/policies/comment_policy.rb`.

---

## Avatar System

Each reply shows a small avatar:
- **If user has profile picture** → Shows their photo (from Cloudinary)
- **If no profile picture** → Shows colored circle with first letter of username

Example: User "john_doe" without avatar → Red circle with "J"

---

## Summary

The comments system is a nested, real-time conversation feature:
- Comments live on place pages
- Replies nest under comments (one level deep)
- @mentions let you tag any user
- Everything updates without page refresh
- Users can only delete their own content
