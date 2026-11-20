# Data Dictionary — Websites, Portals and Communication

Tenant tables carry `school_id`; public CMS data is exposed only through safe published views/API contracts. All files point to the central metadata table described in the shared/storage dictionary.

## 9. School website builder and CMS

### school_websites
`id, school_id FK, website_status, primary_domain_id nullable FK website_domains, default_language, theme_id nullable FK website_themes, settings jsonb, created_by uuid, timestamps`. One website per school unless multi-site feature is approved; website configuration is not private student data.

### website_themes
`id, school_id nullable, name, theme_config jsonb, is_system, is_active, created_at, updated_at`. Platform themes read-only; school themes tenant-owned. Config validated against approved component schema.

### website_pages
`id, school_id FK, website_id FK, parent_page_id nullable FK website_pages, slug, title, page_type, language_code, page_status, seo_title nullable, seo_description nullable, created_by uuid, timestamps`. Unique website/language/slug; draft, review, published, archived lifecycle.

### website_page_versions
`id, school_id FK, page_id FK, version_number, page_content jsonb, change_summary nullable, created_by uuid, created_at, published_at nullable`. Immutable snapshots; content schema versioned.

### website_sections
`id, school_id FK, page_version_id FK, section_key, component_type, position, component_props jsonb, visibility_rules jsonb, created_at`. Only allow-listed component types; no arbitrary executable markup/script.

### website_components
`id, school_id nullable, component_key, component_name, component_schema jsonb, component_version, is_active, created_at`. Platform registry for safe blocks; custom tenant components are config-only.

### website_reusable_blocks
`id, school_id nullable FK, block_key, name, description nullable, component_schema jsonb, component_version, block_content jsonb, visibility, created_by uuid nullable, timestamps`. Platform blocks are read-only; tenant blocks are validated structured content. Reusable blocks must not contain executable custom code.

### website_starter_templates
`id uuid PK, template_key, name, description, supported_school_type, template_version, component_manifest jsonb, default_theme jsonb, is_active, created_at, updated_at`. Platform starter kits (primary, secondary, combined, academy, boarding and blank) are versioned and copied into a school's website configuration; templates do not overwrite a customised site.

### website_navigation
`id, school_id FK, website_id FK, navigation_name, items jsonb, version, updated_by uuid, updated_at`. Validate links and page references; published version snapshot.

### website_media
`id, school_id FK, website_id FK, file_id FK files, media_type, alt_text, caption nullable, copyright_note nullable, consent_reference nullable, created_by uuid, created_at`. Check rights/consent for student images.

### website_articles
`id, school_id FK, website_id FK, title, slug, language_code, body_content jsonb, excerpt nullable, author_user_id uuid, article_status, published_at nullable, featured_media_id nullable FK website_media, timestamps`. Unique slug per website/language.

### website_events
`id, school_id FK, website_id FK, title, description jsonb, starts_at, ends_at nullable, venue nullable, event_status, visibility, created_by uuid, timestamps`. Public events only if approved.

### website_domains
`id, school_id FK, website_id FK, domain_name, domain_type, verification_status, verification_token_hash nullable, is_primary, ssl_status, verified_at nullable, created_at, updated_at`. Unique normalized domain globally; verified before serving; one primary domain per website.

### website_translations
`id, school_id FK, page_id FK, source_language, target_language, translation_status, translated_title nullable, translated_content jsonb nullable, reviewer_user_id nullable, reviewed_at nullable, created_at, updated_at`. Translation references same page identity; publication requires review if policy says so.

### website_publications
`id, school_id FK, website_id FK, page_id FK, page_version_id FK, published_by uuid, published_at, unpublished_at nullable, publication_status, created_at`. Publication event history; public read view uses currently published version only.

### website_seo_settings
`id, school_id FK, website_id FK, page_id nullable FK, canonical_url nullable, robots_directives jsonb, social_metadata jsonb, updated_by uuid, updated_at`.

### website_forms
`id, school_id FK, website_id FK, form_key, title, form_schema jsonb, form_status, destination_workflow, published_at nullable, created_by uuid, timestamps`. Schema validated, anti-spam and retention controls.

### website_form_submissions
`id, school_id FK, form_id FK, submitted_at, payload jsonb, processing_status, assigned_to uuid nullable, source_ip_hash nullable, retention_until nullable, timestamps`. Payload is sensitive; limit collection, access, retention and export.

## 10. Portal and communication

### portal_preferences
`id, school_id FK, user_id FK user_profiles, portal_type, preferences jsonb, updated_at`. Unique school/user/portal.

### portal_notifications
`id, school_id FK, user_id FK user_profiles, notification_type, title, body_safe text, target_path nullable, related_entity_type nullable, related_entity_id uuid nullable, read_at nullable, created_at, expires_at nullable`. Do not embed sensitive detail in push previews; links must re-authorise.

### portal_access_logs
`id, school_id FK, user_id FK, portal_type, accessed_at, device_summary nullable, outcome`. Retention policy and restricted audit access.

### portal_device_tokens
`id, school_id FK, user_id FK, device_token_encrypted, provider, device_label nullable, last_seen_at, revoked_at nullable, created_at`. Unique active token; secret/encrypted data.

### announcements
`id, school_id FK, title, body, audience_type, audience_scope jsonb, publish_at nullable, expires_at nullable, status, author_user_id, timestamps`. Scope validated and resolved to allowed audience.

### message_threads
`id, school_id FK, thread_type, subject nullable, created_by uuid, status, related_student_id nullable FK students, related_entity_type nullable, related_entity_id uuid nullable, timestamps`.

### messages
`id, school_id FK, thread_id FK, sender_user_id FK user_profiles, message_body, sent_at, edited_at nullable, deleted_at nullable, moderation_status, created_at`. Edit/delete actions audited; retention governed.

### message_read_receipts
`id, school_id FK, message_id FK messages, recipient_user_id FK user_profiles, read_at timestamptz, device_context_safe nullable, created_at`. Unique message/recipient; records per-message read receipt. A recipient's last_read_at remains a thread-level convenience, not a substitute for message receipts.

### message_recipients
`id, school_id FK, thread_id FK, user_id FK user_profiles, recipient_role, joined_at, left_at nullable, last_read_at nullable`. Unique active thread/user.

### message_attachments
`id, school_id FK, message_id FK, file_id FK files, created_at`. Permission-checked downloads.

### message_moderation_actions
`id, school_id FK, message_id FK messages, moderator_user_id uuid, action_type, reason nullable, previous_status, new_status, occurred_at`. Append-only moderation history; supports report/review/hide/restore and policy enforcement.

### notification_templates
`id, school_id uuid nullable, template_key, channel, language_code, subject_template nullable, body_template, version, is_active, timestamps`. Tenant override allowed only after template validation.

### notification_deliveries
`id, school_id FK, template_id nullable FK, recipient_user_id nullable FK user_profiles, recipient_contact_hash, channel, provider, provider_message_id nullable, delivery_status, queued_at, sent_at nullable, delivered_at nullable, failed_at nullable, error_code nullable, retry_count, created_at`. Store minimum contact detail; logs sanitized.

### notification_preferences
`id, school_id FK, user_id FK, channel, category, enabled, quiet_hours jsonb nullable, updated_at`. Unique school/user/channel/category; mandatory safety/critical communications override preferences only as policy/law permits.

### communication_provider_logs
`id, school_id FK, provider, channel, event_type, provider_event_id, related_delivery_id nullable FK notification_deliveries, safe_payload jsonb, received_at, processed_at nullable, processing_status`. Idempotent provider event; payload sanitized.
