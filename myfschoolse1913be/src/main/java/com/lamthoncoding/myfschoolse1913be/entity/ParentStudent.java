package com.lamthoncoding.myfschoolse1913be.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "parent_students")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParentStudent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id", nullable = false)
    private Parent parent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    // FATHER, MOTHER, GUARDIAN...
    private String relationship;

    private Boolean emergencyContact;

    private Boolean pickupAuthorized;
}