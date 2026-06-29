package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    List<Attendance> findByClassRoomId(Long classId);

    List<Attendance> findByClassRoomIdAndAttendanceDate(
            Long classId, LocalDate attendanceDate
    );

    List<Attendance> findByClassRoomIdAndAttendanceDateAndPeriod(
            Long classId, LocalDate attendanceDate, Integer period
    );

    @Query("""
    SELECT a
    FROM Attendance a
    WHERE a.classRoom.id = :classId
      AND a.student.id = :studentId
      AND a.attendanceDate BETWEEN :fromDate AND :toDate
    ORDER BY a.attendanceDate DESC, a.period ASC
    """)
    List<Attendance> findAttendanceByMonth(
            @Param("classId") Long classId,
            @Param("studentId") Long studentId,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );



    @Query("""
    SELECT DISTINCT YEAR(a.attendanceDate),
                    MONTH(a.attendanceDate)
    FROM Attendance a
    WHERE a.classRoom.id = :classId
      AND a.student.id = :studentId
    ORDER BY YEAR(a.attendanceDate) DESC,
             MONTH(a.attendanceDate) DESC
    """)
    List<Object[]> findAttendanceMonths(
            @Param("classId") Long classId,
            @Param("studentId") Long studentId
    );
}