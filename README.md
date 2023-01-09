# db2022
Normalization of a database as a school project at ITHS. In this repository your will find a script to normalize a database, a ER model to show the relationships in the normalized data and a JBDC CRUD.

To make this diagram we have used Mermaid, which is a tool to be able to draw a diagram using markdown language. 

# ER diagram

![mermaid-diagram-2023-01-09-195722](https://user-images.githubusercontent.com/117780904/211386390-89152562-cefa-4e38-bfe4-1f880b848a36.png)


erDiagram

    STUDENT {
        int studentId
        String name
    }

    STUDENT ||--o| GRADE : has
    GRADE {
        String grade
        int studentId
    }

    STUDENT ||--o{ PHONE : has
    PHONE {
        int studentID
        String homePhone
        String jobPhone
        String mobilePhone

    }

    STUDENT ||--o{ STUDENTSCHOOL : attends
    STUDENTSCHOOL {
        int studentId
        int schoolId
    }

        STUDENTSCHOOL }o--|| SCHOOL : enrolls
        SCHOOL{
            int schoolId
            String name
            String city
        }

    STUDENT ||--o{ STUDENTHOBBY : has
    STUDENTHOBBY {
        int studentId
        int hobbyId
    }

        STUDENTHOBBY ||--o{ HOBBY : involves
        HOBBY{
            int hobbyId
            String name
        }

