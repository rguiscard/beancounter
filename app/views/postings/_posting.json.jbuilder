json.extract! posting, :id, :flag, :account, :arguments, :comment, :entry_id, :created_at, :updated_at
json.url posting_url(posting, format: :json)
