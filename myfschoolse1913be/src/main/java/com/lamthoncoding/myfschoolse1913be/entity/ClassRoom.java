package com.lamthoncoding.myfschoolse1913be.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "class_rooms")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassRoom extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String className;

    private String schoolYear; // 2026-2027

    @OneToOne
    @JoinColumn(name = "homeroom_teacher_id")
    private Teacher homeroomTeacher;

    @OneToMany(mappedBy = "classRoom")
    private List<Student> students;
}