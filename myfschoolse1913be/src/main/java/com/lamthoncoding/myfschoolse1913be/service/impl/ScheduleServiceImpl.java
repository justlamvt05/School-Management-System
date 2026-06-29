package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.ScheduleMapper;
import com.lamthoncoding.myfschoolse1913be.payload.response.ScheduleResponse;
import com.lamthoncoding.myfschoolse1913be.repository.ClassRoomRepository;
import com.lamthoncoding.myfschoolse1913be.repository.ScheduleRepository;
import com.lamthoncoding.myfschoolse1913be.service.ScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleServiceImpl implements ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final ClassRoomRepository classRoomRepository;
    private final ScheduleMapper scheduleMapper;

    @Override
    public List<ScheduleResponse> getScheduleByClass(Long classId) {

        log.info("Get schedule of class {}", classId);

        classRoomRepository.findById(classId)
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        return scheduleRepository.findByClassRoomId(classId)
                .stream()
                .map(scheduleMapper::toResponse)
                .toList();
    }

    @Override
    public List<ScheduleResponse> getScheduleByClassAndDay(Long classId, DayOfWeek dayOfWeek) {

        log.info("Get schedule of class {} on {}", classId, dayOfWeek);

        classRoomRepository.findById(classId)
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        return scheduleRepository.findByClassRoomIdAndDayOfWeek(classId, dayOfWeek)
                .stream()
                .map(scheduleMapper::toResponse)
                .toList();
    }
}
