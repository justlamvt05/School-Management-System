package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.contraints.EventTargetRole;
import com.lamthoncoding.myfschoolse1913be.entity.Event;
import com.lamthoncoding.myfschoolse1913be.payload.response.EventResponse;
import com.lamthoncoding.myfschoolse1913be.repository.EventRepository;
import com.lamthoncoding.myfschoolse1913be.service.EventService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class EventServiceImpl implements EventService {

    private final EventRepository eventRepository;

    @Override
    public List<EventResponse> getAllEvents() {
        log.info("Fetching all events");
        return eventRepository.findByTargetRoleInOrderByStartTimeDesc(
                        List.of(EventTargetRole.ALL, EventTargetRole.TEACHER, EventTargetRole.STUDENT))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<EventResponse> getEventsForTeacher() {
        log.info("Fetching events for teacher");
        return eventRepository.findByTargetRoleInOrderByStartTimeDesc(
                        List.of(EventTargetRole.ALL, EventTargetRole.TEACHER))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<EventResponse> getEventsForStudent() {
        log.info("Fetching events for student");
        return eventRepository.findByTargetRoleInOrderByStartTimeDesc(
                        List.of(EventTargetRole.ALL, EventTargetRole.STUDENT))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private EventResponse toResponse(Event event) {
        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .location(event.getLocation())
                .startTime(event.getStartTime())
                .endTime(event.getEndTime())
                .targetRole(event.getTargetRole())
                .createdByName(event.getCreatedBy() != null ? event.getCreatedBy().getFullName() : null)
                .build();
    }
}
