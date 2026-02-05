# Pet Manager API Specification

This document describes the backend API endpoints required by the iOS app.

## Base URL
```
http://localhost:8000
```

## Date Formats

- **Pet dates** (birthday): `YYYY-MM-DD` format (Python `date` type). Example: `"2023-05-15"`
- **Appointment dates**: ISO8601 datetime format. Example: `"2026-02-10T10:30:00Z"`

---

## Pet Model

```json
{
  "id": 1,
  "name": "Willow",
  "species": "Cocker Spaniel",
  "age": 3,
  "description": "A sweet and energetic dog",
  "weight": 12.5,
  "gender": "Female",
  "color": "Golden",
  "birthday": "2023-01-15"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | integer | Yes | Unique identifier |
| name | string | Yes | Pet's name |
| species | string | Yes | Breed/species (maps to `breed` in iOS) |
| age | integer | Yes | Age in years |
| description | string | Yes | About the pet |
| weight | number | Yes | Weight in kg |
| gender | string | Yes | "Male" or "Female" |
| color | string | No | Coat color (e.g., "Golden", "Black", "Brindle") |
| birthday | string (YYYY-MM-DD) | No | Pet's birthday |

---

## Endpoints

### GET /pets/{id}
Fetch a single pet by ID.

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Willow",
  "species": "Cocker Spaniel",
  "age": 3,
  "description": "A sweet dog",
  "weight": 12.5,
  "gender": "Female",
  "color": "Golden",
  "birthday": "2023-01-15"
}
```

---

### GET /users/{userId}/pets
Fetch all pets for a specific user.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Willow",
    "species": "Cocker Spaniel",
    "age": 3,
    "description": "A sweet dog",
    "weight": 12.5,
    "gender": "Female",
    "color": "Golden",
    "birthday": "2023-01-15"
  }
]
```

---

### POST /pets
Create a new pet (no user association).

**Request Body:**
```json
{
  "name": "Buddy",
  "species": "Golden Retriever",
  "age": 2,
  "description": "Friendly dog",
  "weight": 30.0,
  "gender": "Male",
  "color": "Golden",
  "birthday": "2024-03-20"
}
```

**Response:** `201 Created`
Returns the created pet with assigned `id`.

---

### POST /users/{userId}/pets
Create a new pet for a specific user.

**Request Body:** Same as `POST /pets`

**Response:** `201 Created`
Returns the created pet with assigned `id`.

---

### PATCH /pets/{id}
Update an existing pet. All fields are optional - only include fields to update.

**Request Body (partial update example):**
```json
{
  "gender": "Female",
  "color": "Brindle",
  "birthday": "2022-06-10",
  "age": 4
}
```

**Response:** `200 OK`
Returns the full updated pet object.

**Used by:**
- **AgeView** - Updates `birthday` and `age` fields
- **GenderView** - Updates `gender` field
- **ColorView** - Updates `color` field

---

### DELETE /pets/{id}
Delete a pet.

**Response:** `204 No Content`

---

## Appointment Model

```json
{
  "id": 1,
  "appointment_date": "2026-02-10T10:30:00",
  "reason": "Annual Checkup",
  "vet_name": "Dr. Smith",
  "location": "Happy Paws Clinic",
  "notes": "Bring vaccination records",
  "status": "scheduled",
  "pet_id": 22
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | integer | Yes | Unique identifier |
| appointment_date | datetime | Yes | Date and time of appointment (ISO8601) |
| reason | string | Yes | Reason for the appointment |
| vet_name | string | No | Veterinarian name |
| location | string | No | Clinic/hospital location |
| notes | string | No | Additional notes |
| status | string | Yes | "scheduled", "completed", or "cancelled" |
| pet_id | integer | Yes | Associated pet ID |

---

### GET /pets/{petId}/appointments
Fetch all appointments for a specific pet.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "appointment_date": "2026-02-10T10:30:00",
    "reason": "Annual Checkup",
    "vet_name": "Dr. Smith",
    "location": "Happy Paws Clinic",
    "notes": "Bring vaccination records",
    "status": "scheduled",
    "pet_id": 22
  }
]
```

---

### POST /pets/{petId}/appointments
Create a new appointment for a pet.

**Request Body:**
```json
{
  "appointment_date": "2026-02-10T10:30:00Z",
  "reason": "Annual Checkup",
  "vet_name": "Dr. Smith",
  "location": "Happy Paws Clinic",
  "notes": "Bring vaccination records",
  "status": "scheduled"
}
```

**Response:** `201 Created`
Returns the created appointment with assigned `id` and `pet_id`.

---

### PATCH /appointments/{id}
Update an existing appointment. All fields are optional.

**Request Body (partial update example):**
```json
{
  "status": "completed",
  "notes": "Checkup complete, all vaccinations up to date"
}
```

**Response:** `200 OK`
Returns the full updated appointment object.

---

### DELETE /appointments/{id}
Delete an appointment.

**Response:** `204 No Content`

---

## New Field: birthday

The `birthday` field was added to support the AgeView feature. When a birthday is set:

1. The app calculates age from the birthday
2. The app shows days until next birthday
3. The app displays life stage based on age

**Backend Requirements:**
- Store `birthday` as a nullable date field (Python `date` type)
- Return `birthday` in `YYYY-MM-DD` format when present
- Accept `birthday` in `YYYY-MM-DD` format on create/update
- If `birthday` is `null` or omitted, the field should be absent or null in response

---

## Example PATCH Requests

### Update Gender
```bash
curl -X PATCH http://localhost:8000/pets/1 \
  -H "Content-Type: application/json" \
  -d '{"gender": "Female"}'
```

### Update Color
```bash
curl -X PATCH http://localhost:8000/pets/1 \
  -H "Content-Type: application/json" \
  -d '{"color": "Brindle"}'
```

### Update Birthday and Age
```bash
curl -X PATCH http://localhost:8000/pets/1 \
  -H "Content-Type: application/json" \
  -d '{"birthday": "2022-01-15", "age": 4}'
```
