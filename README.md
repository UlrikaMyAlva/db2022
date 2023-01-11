# db2022
Normalization of a database as a school project at ITHS. In this repository your will find a script to normalize a database, a ER model to show the relationships in the normalized data and a JBDC CRUD.

To make this diagram we have used Mermaid, which is a tool to be able to draw a diagram using markdown language. 

# ER diagram

![mermaid-diagram-2023-01-11-181400](https://user-images.githubusercontent.com/117780904/211872360-f6637edd-19df-463b-a40d-15655df05e8b.png)


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

