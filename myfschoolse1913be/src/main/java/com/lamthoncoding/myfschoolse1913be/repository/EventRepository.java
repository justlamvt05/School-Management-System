package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.contraints.EventTargetRole;
import com.lamthoncoding.myfschoolse1913be.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EventRepository extends JpaRepository<Event, Long> {

    List<Event> findByTargetRoleInOrderByStartTimeDesc(List<EventTargetRole> roles);
}
