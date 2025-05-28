# Vakeel - Your Personal Legal Assistant

Vakeel is a mobile application available for both Android and iOS platforms, designed to bring legal knowledge into the hands of every citizen. It serves as a personal legal assistant, offering round-the-clock access to legal information and guidance in a user-friendly and accessible manner.

> **Note:** For the current implementation status and testing instructions, please see the [STATUS.md](STATUS.md) file.

## Features

- **Real-time Legal Responses**: Get instant responses to your legal queries
- **Query History**: Access your past legal questions and answers
- **Save Important Information**: Bookmark critical legal advice for future reference
- **User Profiles**: Personalized experience with user accounts
- **Expert Legal Knowledge**: Designed to be powered by a trained Llama2 language model (currently using a mock service for demonstration)

## Project Architecture

### Frontend (Flutter)
- Written in Dart using the Flutter framework for cross-platform mobile development
- Reactive UI with Provider for state management
- Secure data storage with flutter_secure_storage
- HTTP client with dio for API communication

### Backend (FastAPI)
- RESTful API built with FastAPI
- SQLite database with SQLAlchemy ORM
- JWT authentication for secure user sessions
- Mock LLM service (with option to integrate with Llama2 LLM for generating legal responses)
- Categorization of legal queries

## Getting Started

### Backend Setup

1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Set up the database:
   ```bash
   python create_db.py
   ```

3. Run the application:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8080 --reload
   ```
   
   or use the provided batch file:
   ```bash
   run_backend.bat
   ```

4. Access the API documentation at http://127.0.0.1:8080/docs

> **Note:** The backend uses a mock LLM service implementation that provides predefined legal responses without requiring the full Llama2 model. This makes it much lighter and easier to run on any system.

### Frontend Setup

#### Option 1: Install Flutter and Run the App
1. Install Flutter SDK using the provided script:
   ```bash
   setup_flutter.bat
   ```
   
2. After installation, restart your terminal and run the frontend app:
   ```bash
   run_frontend.bat
   ```

#### Option 2: View the HTML Preview
If Flutter is not available, you can view a static HTML preview of the app UI:
   ```bash
   start frontend\preview.html
   ```

## Database Schema

- **Users**: Stores user authentication information
- **Profiles**: Contains user profile data
- **LegalQueries**: Stores the legal questions and their corresponding AI-generated answers

## LLM Integration

Vakeel uses Llama2, a state-of-the-art language model fine-tuned for legal domain knowledge. The model processes user queries to generate accurate and helpful legal information.

## Project Goals

- Bridge the gap between legal experts and the general public
- Make legal information accessible to all
- Create a community of legally informed citizens
- Provide a reliable first point of contact for legal questions

## Note

Vakeel provides information for educational purposes only and does not substitute professional legal advice. Always consult with a qualified attorney for specific legal matters.

## License

[MIT License](LICENSE)
