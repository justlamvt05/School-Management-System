package com.lamthoncoding.myfschoolse1913be.entity;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "semesters")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Semester extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String semesterName; // HK1, HK2

    private String schoolYear;
}