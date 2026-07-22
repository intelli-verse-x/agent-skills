---
name: ivx-cf-api-design
description: Design RESTful and GraphQL APIs with proper validation, versioning, and documentation. Use when creating new endpoints, designing request/response models, or reviewing API contracts.
---
# API Design Skill

## Purpose

Design APIs that are intuitive, consistent, evolvable, and well-documented.

## Design Principles

1. **Resource-oriented**: Nouns, not verbs (`/tasks` not `/createTask`)
2. **Predictable**: Consistent patterns across all endpoints
3. **Self-descriptive**: Clear error messages, hypermedia where appropriate
4. **Evolvable**: Backward compatible changes, clear deprecation

## URL Structure

```
/api/v1/{resource}           # Collection
/api/v1/{resource}/{id}      # Single resource
/api/v1/{resource}/{id}/{subresource}  # Sub-collection
```

## HTTP Methods

| Method | Collection | Single Resource |
|--------|-----------|----------------|
| GET | List (paginated) | Retrieve |
| POST | Create | N/A |
| PUT | Bulk update | Full update |
| PATCH | N/A | Partial update |
| DELETE | N/A | Delete |

## Request/Response

### Success
```json
{
  "success": true,
  "data": { ... },
  "meta": { "page": 1, "limit": 20, "total": 100 }
}
```

### Error
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [{"field": "duration", "issue": "must be >= 5"}]
  }
}
```

## Validation

- Pydantic models for all bodies
- Field validators with clear messages
- Business rules in service layer
- Return 422 for validation errors with detailed info

## Versioning

- URL path: `/api/v1/`, `/api/v2/`
- Deprecation: `Sunset` header, 6-month notice
- Breaking changes → new version
- Document migration path

## Pagination

```
GET /api/v1/tasks?page=1&limit=20
```

- Cursor-based for large datasets (better perf)
- Offset-based for small, stable datasets
- Always include `total`, `has_more`

## Idempotency

- `Idempotency-Key` header for POST/PUT/PATCH
- Key scoped to resource + operation
- TTL: 24 hours minimum
- Return cached response for replay

## CF-Specific

- All pipelines: `POST /api/pipelines/{kind}`
- Task status: `GET /api/pipelines/tasks/{id}`
- Harvest: `GET /api/pipelines/tasks/{id}/harvest`
- Tags in request for operator-loop discovery
