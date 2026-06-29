package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.DayOfWeek;
import java.util.List;

public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    List<Schedule> findByClassRoomId(Long classRoomId);

    List<Schedule> findByClassRoomIdAndDayOfWeek(Long classRoomId, DayOfWeek dayOfWeek);

    List<Schedule> findByTeacherId(Long teacherId);

    List<Schedule> findByTeacherIdAndDayOfWeek(Long teacherId, DayOfWeek dayOfWeek);

    List<Schedule> findByTeacherIdAndClassRoomIdAndSubjectId(Long teacherId, Long classRoomId, Long subjectId);

    List<Schedule> findByTeacherIdAndClassRoomIdAndDayOfWeek(Long teacherId, Long classRoomId, DayOfWeek dayOfWeek);
}
