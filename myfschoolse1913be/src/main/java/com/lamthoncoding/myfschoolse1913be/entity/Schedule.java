package com.lamthoncoding.myfschoolse1913be.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.DayOfWeek;

@Entity
@Table(name = "schedules")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Schedule extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "class_room_id")
    private ClassRoom classRoom;

    @ManyToOne
    @JoinColumn(name = "subject_id")
    private Subject subject;

    private DayOfWeek dayOfWeek;

    private Integer periodStart;

    private Integer periodEnd;

    private String room;

    @ManyToOne
    @JoinColumn(name = "teacher_id")
    private Teacher teacher;
}